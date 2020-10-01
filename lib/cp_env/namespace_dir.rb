class CpEnv
  class NamespaceDir
    attr_reader :cluster, :dir
    attr_reader :executor

    # Hardcoded context is required to switch to the manager cluster
    MANAGER_CLUSTER = "manager.cloud-platform.service.justice.gov.uk"

    def initialize(args)
      @dir = args.fetch(:dir)
      @cluster = args.fetch(:cluster)
      @executor = args.fetch(:executor) { Executor.new }
    end

    def apply
      return unless FileTest.directory?(dir)
      executor.execute("git pull") # In case any PRs were merged since the pipeline started
      apply_namespace_dir
    end

    private

    def namespace
      File.basename(dir)
    end

    def team_name
      @team_name ||= begin
        yaml = YAML.load(File.read("#{dir}/01-rbac.yaml"))
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
