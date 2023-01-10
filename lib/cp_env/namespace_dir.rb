class CpEnv
  class NamespaceDir
    attr_reader :cluster, :dir, :enable_skip_namespaces
    attr_reader :executor

    # Hardcoded context is required to switch to the manager cluster
    MANAGER_CLUSTER = "manager.cloud-platform.service.justice.gov.uk"

    # If these file exists in a namespace folder, and enable_skip_namespaces is
    # `true`, calling `apply` on the namespace will do nothing.
    SKIP_FILE = "APPLY_PIPELINE_SKIP_THIS_NAMESPACE"
    # If SECRET_ROTATION file exists, the pipeline will skip the namespace as it must Note
    # apply the secrets rotation script until the user removes the file.
    SECRET_ROTATION = "SECRET_ROTATION_IN_PROGRESS"

    def initialize(args)
      @dir = args.fetch(:dir)
      @cluster = args.fetch(:cluster)
      @executor = args.fetch(:executor) { Executor.new }
      @enable_skip_namespaces = args.fetch(:enable_skip_namespaces, true)
      @enable_secret_rotation = args.fetch(:enable_skip_namespaces, true)
    end

    def apply
      return if ignore_this_namespace?

      executor.execute("git pull") # In case any PRs were merged since the pipeline started
      apply_namespace_dir
    end

    private

    def ignore_this_namespace?
      return true unless FileTest.directory?(dir)

      if (enable_skip_namespaces && FileTest.exist?("#{dir}/#{SKIP_FILE}")) || FileTest.exist?("#{dir}/#{SECRET_ROTATION}")
        log("red", "#{namespace}/#{SKIP_FILE} or #{namespace}/#{SECRET_ROTATION} file exists. Skipping this namespace.")
        true
      else
        false
      end
    end

    def namespace
      File.basename(dir)
    end

    def team_name
      @team_name ||= begin
        yaml = YAML.safe_load(File.read("#{dir}/01-rbac.yaml"))
        team = yaml["subjects"][0].dig("name").split(":")[1]
        abort("Team name not found") if team.nil?
        team
      end
    end

    def apply_namespace_dir
      apply_kubernetes_files
      apply_terraform
    end

    def apply_kubernetes_files
      if contains_kubernetes_files?
        log("green", "applying #{namespace}")
        executor.execute("kubectl -n #{namespace} apply -f #{dir}")
      end
    end

    def contains_kubernetes_files?
      Dir.glob("#{dir}/*.{yaml,yml,json}").any?
    end

    def apply_terraform
      Terraform.new(cluster: cluster, namespace: namespace, dir: dir).apply
    end
  end
end
