# This is a library of shared functions
# used by our concourse pipeline apply
# scripts

require "open3"

def set_kube_context(cluster)
  execute("kubectl config use-context #{cluster}")
end

def apply_cluster_level_resources(cluster)
  log("blue", "applying cluster-level resources for #{cluster}")
  _, _, status = execute("kubectl apply -f namespaces/#{cluster}", can_fail: true)
  log("blue", "no global resources to apply") unless status.success?
end

def apply_namespace_dir(cluster, dir)
  return unless FileTest.directory?(dir)

  namespace = File.basename(dir)
  apply_kubernetes_files(cluster, namespace, dir)
  deploy_serviceaccount(cluster, namespace, dir)
  apply_terraform(cluster, namespace, dir)
end

def deploy_serviceaccount(_cluster, namespace, dir)
  log("green", "creating #{namespace} deploy user")
  execute("kubectl apply -f #{dir}/05-deploy-serviceaccount")
end

def apply_kubernetes_files(_cluster, namespace, dir)
  log("green", "applying #{namespace}")
  execute("kubectl -n #{namespace} apply -f #{dir}")
end

def apply_terraform(cluster, namespace, dir)
  tf_dir = File.join(dir, "resources")
  return unless FileTest.directory?(tf_dir)

  log("blue", "applying terraform resources for namespace #{namespace} in #{cluster}")
  tf_init(cluster, namespace, tf_dir)
  tf_apply(cluster, namespace, tf_dir)
end

def tf_init(cluster, namespace, dir)
  bucket = ENV.fetch("PIPELINE_STATE_BUCKET")
  key_prefix = ENV.fetch("PIPELINE_STATE_KEY_PREFIX")
  lock_table = ENV.fetch("PIPELINE_TERRAFORM_STATE_LOCK_TABLE")
  region = ENV.fetch("PIPELINE_STATE_REGION")
  key = "#{key_prefix}#{cluster}/#{namespace}/terraform.tfstate"

  cmd = [
    %(terraform init),
    %(-backend-config="bucket=#{bucket}"),
    %(-backend-config="key=#{key}"),
    %(-backend-config="dynamodb_table=#{lock_table}"),
    %(-backend-config="region=#{region}"),
  ].join(" ")

  execute("cd #{dir}; #{cmd}")
end

def tf_apply(cluster, namespace, dir)
  bucket = ENV.fetch("PIPELINE_CLUSTER_STATE_BUCKET")
  key_prefix = ENV.fetch("PIPELINE_CLUSTER_STATE_KEY_PREFIX")

  name = cluster.split(".").first
  key = "cluster_state_key=#{key_prefix}#{name}/terraform.tfstate"

  cmd = [
    %(terraform apply),
    %(-var="cluster_name=#{name}"),
    %(-var="cluster_state_bucket=#{bucket}"),
    %(-var="cluster_state_key=#{key}"),
    %(-auto-approve),
  ].join(" ")

  execute("cd #{dir}; #{cmd}")
end

def execute(cmd, can_fail: false)
  log("blue", "executing: #{cmd}")
  stdout, stderr, status = Open3.capture3(cmd)

  unless can_fail || status.success?
    log("red", "Command: #{cmd} failed.")
    puts stderr
    raise
  end

  puts stdout

  [stdout, stderr, status]
end

def log(colour, message)
  colour_code = case colour
  when "red"
    31
  when "blue"
    34
  when "green"
    32
  else
    raise "Unknown colour #{colour} passed to 'log' method"
  end

  puts "\e[#{colour_code}m#{message}\e[0m"
end
