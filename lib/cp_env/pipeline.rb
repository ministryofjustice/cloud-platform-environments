# This is a library of shared functions
# used by our concourse pipeline apply
# scripts

def changed_namespace_dirs_for_plan(cluster)
  # these env vars are provided by the github-pull-request concourse resource.
  main_base_sha = ENV.fetch("main_base_sha")
  branch_head_sha = ENV.fetch("branch_head_sha")

  (changed_files, _, _) = execute("git diff --no-commit-id --name-only -r #{main_base_sha}...#{branch_head_sha}")

  namespace_dirs_from_changed_files(cluster, changed_files)
end

def changed_namespace_dirs(cluster)
  (changed_files, _, _) = execute("git diff --no-commit-id --name-only -r HEAD~1..HEAD")

  namespace_dirs_from_changed_files(cluster, changed_files)
end

def deleted_namespaces(cluster)
  changed_namespace_dirs(cluster)
    .find_all { |dir| !FileTest.directory?(dir) }
    .map { |dir| dir.split("/").last }
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

def plan_namespace_dir(cluster, dir)
  return unless FileTest.directory?(dir)

  namespace = File.basename(dir)
  dryrun_kubernetes_files(cluster, namespace, dir)
  plan_terraform(cluster, namespace, dir)
end

def dryrun_kubernetes_files(_cluster, namespace, dir)
  if contains_kubernetes_files?(dir)
    log("green", "Dry-run #{namespace}")
    execute("kubectl -n #{namespace} apply --dry-run -f #{dir}")
  end
end

def plan_terraform(cluster, namespace, dir)
  CpEnv::Terraform.new(cluster: cluster, namespace: namespace, dir: dir).plan
end

def contains_kubernetes_files?(dir)
  Dir.glob("#{dir}/*.{yaml,yml,json}").any?
end

def apply_terraform(cluster, namespace, dir)
  Terraform.new(cluster: cluster, namespace: namespace, dir: dir).apply
end

def execute(cmd, can_fail: false, silent: false)
  CpEnv::Executor.new.execute(cmd, can_fail: can_fail, silent: silent)
end

def log(colour, message)
  CpEnv::Logger.new.log(colour, message)
end
