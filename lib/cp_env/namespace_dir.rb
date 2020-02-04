class CpEnv
  class NamespaceDir
    attr_reader :cluster, :dir
    attr_reader :executor

    GITOPS_RESOURCES_FILE = "resources/gitops.tf"
    # An ARN is required to switch context to the manager EKS cluster
    MANAGER_CLUSTER = "arn:aws:eks:eu-west-2:754256621582:cluster/manager"

    def initialize(args)
      @dir = args.fetch(:dir)
      @cluster = args.fetch(:cluster)
      @executor = args.fetch(:executor) { Executor.new }
    end

    def apply
      return unless FileTest.directory?(dir)

      executor.execute("git pull") # In case any PRs were merged since the pipeline started

      if gitops_namespace?
        apply_gitops_namespace_dir
        GitopsGpgKeypair.new(namespace: namespace, team_name: team_name).generate_and_store
      else
        apply_namespace_dir
      end
    end

    private

    def namespace
      File.basename(dir)
    end

    def gitops_namespace?
      FileTest.exists?(File.join(dir, GITOPS_RESOURCES_FILE))
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

    def apply_gitops_namespace_dir
      return unless FileTest.directory?(dir)

      apply_kubernetes_files
      create_gitops_kubeconfig
      apply_terraform
    end

    # Creates a concourse-<team-name> namespace and a kubeconfig secret inside.
    # The kubeconfig file is pulled down locally as part of the build-environments pipeline.
    def create_gitops_kubeconfig
      log("green", "creating kubeconfig secret inside concourse-#{team_name}")
      set_kube_context(MANAGER_CLUSTER)
      unless team_namespace_exists?
        executor.execute("kubectl create ns concourse-#{team_name}")
      end

      unless secret_exists?
        executor.execute("kubectl -n concourse-#{team_name} create secret generic kubectl-conf --from-file=$KUBECONFIG")
      end
      set_kube_context(cluster)
    end

    def team_namespace_exists?
      system("kubectl get ns | grep concourse-#{team_name}")
    end

    def secret_exists?
      system("kubectl -n concourse-#{team_name} get secret kubectl-conf")
    end
  end
end
