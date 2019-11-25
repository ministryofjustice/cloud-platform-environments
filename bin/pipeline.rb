# This is a library of shared functions
# used by our concourse pipeline apply
# scripts

require "open3"

class Terraform
  attr_reader :cluster, :namespace, :dir
  attr_reader :bucket, :key_prefix, :lock_table, :region

  def initialize(args)
    @cluster = args.fetch(:cluster)
    @namespace = args.fetch(:namespace)
    @dir = args.fetch(:dir)

    @bucket = ENV.fetch("PIPELINE_STATE_BUCKET")
    @key_prefix = ENV.fetch("PIPELINE_STATE_KEY_PREFIX")
    @lock_table = ENV.fetch("PIPELINE_TERRAFORM_STATE_LOCK_TABLE")
    @region = ENV.fetch("PIPELINE_STATE_REGION")

    # These env vars must exist, in case any terraform modules need them.
    # Not all modules need them, but we have no way of knowing in advance
    # which do and which don't.
    # Terraform prior to 0.12 would allow us to pass these via command-line
    # flags, and just ignore them if they weren't used, but terraform 0.12
    # raises an error if you pass an unused variable on the command-line.
    # However, it's not so strict about environment variables, so we can
    # ensure that our pipelines always set these env. vars. This check is
    # here so that we get a sensible error if we ever fail to do that.
    %w[
      TF_VAR_cluster_name
      TF_VAR_cluster_state_bucket
      TF_VAR_cluster_state_key
    ].each { |var| ENV.fetch(var) }
  end

  def plan
    return unless FileTest.directory?(tf_dir)

    log("blue", "planning terraform resources for namespace #{namespace} in #{cluster}")
    tf_init
    tf_plan
  end

  def apply
    return unless FileTest.directory?(tf_dir)

    log("blue", "applying terraform resources for namespace #{namespace} in #{cluster}")
    tf_init
    tf_apply
  end

  private

  def terraform_executable
    # The `terraform 0.12upgrade` creates a `versions.tf` file, so we can
    # use the existence of that file to identify terraform 0.12 source code
    FileTest.exists?("#{tf_dir}/versions.tf") ? "terraform12" : "terraform"
  end

  def tf_init
    key = "#{key_prefix}#{cluster}/#{namespace}/terraform.tfstate"

    cmd = [
      %(#{terraform_executable} init),
      %(-backend-config="bucket=#{bucket}"),
      %(-backend-config="key=#{key}"),
      %(-backend-config="dynamodb_table=#{lock_table}"),
      %(-backend-config="region=#{region}"),
    ].join(" ")

    execute("cd #{tf_dir}; #{cmd}")
  end

  def tf_apply
    cmd = tf_cmd(
      operation: "apply",
      last: %(-auto-approve),
    )

    execute("cd #{tf_dir}; #{cmd}")
  end

  def tf_plan
    cmd = tf_cmd(
      operation: "plan",
      last: %( | grep -vE '^(\\x1b\\[0m)?\\s{3,}'),
    )

    execute("cd #{tf_dir}; #{cmd}")
  end

  def tf_dir
    File.join(dir, "resources")
  end

  def tf_cmd(opts)
    operation = opts.fetch(:operation)
    last = opts.fetch(:last)

    "#{terraform_executable} #{operation} #{last}"
  end
end

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

def apply_namespace_dir(cluster, dir, team_name)
  return unless FileTest.directory?(dir)

  namespace = File.basename(dir)
  apply_kubernetes_files(cluster, namespace, dir)
  apply_gitops_kubernetes_files(cluster, team_name, dir)
  apply_terraform(cluster, namespace, dir)
end

def plan_namespace_dir(cluster, dir)
  return unless FileTest.directory?(dir)

  namespace = File.basename(dir)
  Terraform.new(cluster: cluster, namespace: namespace, dir: dir).plan
end

def apply_kubernetes_files(_cluster, namespace, dir)
  log("green", "applying #{namespace}")
  execute("kubectl -n #{namespace} apply -f #{dir}")
end

def apply_gitops_kubernetes_files(_cluster, namespace, dir)
  log("green", "applying concourse-#{team_name}")
  execute("kubectl -n concourse-#{team_name} apply -f #{dir}/gitops-resources")
end

def apply_terraform(cluster, namespace, dir)
  Terraform.new(cluster: cluster, namespace: namespace, dir: dir).apply
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
