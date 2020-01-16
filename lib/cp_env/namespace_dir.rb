class CpEnv
  class NamespaceDir
    attr_reader :cluster, :dir
    attr_reader :executor

    GITOPS_RESOURCES_DIR = "gitops-resources"

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
      FileTest.exists?(File.join(dir, GITOPS_RESOURCES_DIR))
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
      apply_gitops_kubernetes_files
      create_gitops_kubeconfig
      apply_terraform
    end

    def create_gitops_kubeconfig
      log("green", "creating kubeconfig file inside concourse-#{team_name}")
      # grab kubeconfig file from s3
      # base64 encode contents of file
      # create k8s secret with contents of kubeconfig

      #s3 = Aws::S3::Client.new
      #obj = s3.get_object(bucket:'cloud-platform-concourse-kubeconfig', key:'gitops-config')

      #config = obj.read
      executor.execute("kubectl -n concourse-#{team_name} create secret generic kubectl-conf --from-file=/tmp/kubeconfig")
    end

    def apply_gitops_kubernetes_files
      log("green", "applying concourse-#{team_name}")
      executor.execute("kubectl -n concourse-#{team_name} apply -f #{dir}/gitops-resources")
    end
  end
end
