# This is a library of shared functions
# used by our concourse pipeline apply
# scripts

require "open3"

def changed_namespace_dirs_for_plan(cluster)
  # these env vars are provided by the github-pull-request concourse resource.
  master_base_sha = ENV.fetch("master_base_sha")
  branch_head_sha = ENV.fetch("branch_head_sha")

  (changed_files, _, _) = execute("git diff --no-commit-id --name-only -r #{master_base_sha}...#{branch_head_sha}")

  namespace_dirs_from_changed_files(cluster, changed_files)
end

def changed_namespace_dirs(cluster)
  (changed_files, _, _) = execute("git diff --no-commit-id --name-only -r HEAD~1..HEAD")

  namespace_dirs_from_changed_files(cluster, changed_files)
end

def namespace_dirs_from_changed_files(cluster, files)
  namespace_regex = %r{namespaces.#{cluster}}

  files
    .split("\n")
    .grep(namespace_regex) # ignore changes outside namespace directories
    .map { |f| File.dirname(f) }
    .map { |f| f.split("/") }
    .map { |arr| File.join(arr[0..2]) } # discard the ".../resources" part of the path
    .sort
    .uniq
end

def all_namespace_dirs(cluster)
  Dir["namespaces/#{cluster}/*"].sort
end

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
  apply_terraform(cluster, namespace, dir)
end

def plan_namespace_dir(cluster, dir)
  return unless FileTest.directory?(dir)

  namespace = File.basename(dir)
  plan_terraform(cluster, namespace, dir)
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

def plan_terraform(cluster, namespace, dir)
  tf_dir = File.join(dir, "resources")
  return unless FileTest.directory?(tf_dir)

  log("blue", "planning terraform resources for namespace #{namespace} in #{cluster}")
  tf_init(cluster, namespace, tf_dir)
  tf_plan(cluster, namespace, tf_dir)
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
  cmd = tf_cmd(
    cluster: cluster,
    operation: "apply",
    last: %(-auto-approve),
  )

  execute("cd #{dir}; #{cmd}")
end

def tf_plan(cluster, namespace, dir)
  cmd = tf_cmd(
    cluster: cluster,
    operation: "plan",
    last: %( | grep -vE '^(\\x1b\\[0m)?\\s{3,}'),
  )

  execute("cd #{dir}; #{cmd}")
end

def tf_cmd(opts)
  operation = opts.fetch(:operation)
  cluster = opts.fetch(:cluster)
  last = opts.fetch(:last)

  bucket = ENV.fetch("PIPELINE_CLUSTER_STATE_BUCKET")
  key_prefix = ENV.fetch("PIPELINE_CLUSTER_STATE_KEY_PREFIX")

  name = cluster.split(".").first
  key = "#{key_prefix}#{name}/terraform.tfstate"

  [
    %(terraform #{operation}),
    %(-var="cluster_name=#{name}"),
    %(-var="cluster_state_bucket=#{bucket}"),
    %(-var="cluster_state_key=#{key}"),
    last,
  ].join(" ")
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
