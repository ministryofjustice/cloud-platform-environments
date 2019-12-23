class CpEnv
  class NamespaceDeleter
    # Class to delete a namespace's AWS resources, and then the namespace
    # itself. The order is important, because deleting the AWS resources is
    # more likely to fail than deleting the namespace, and if the namespace is
    # deleted, we'll never try again to delete any AWS resources.
    #
    # This class will not do anything if a) there is still a
    # `namespaces/[cluster]/[namespace]` folder, or b) the namespace has
    # `is-production` set to `true`
    #
    # Assumption: The script which invokes this class is being called from the
    # root of an up to date working copy of the environments repo.

    attr_reader :namespace, :k8s_client

    CLUSTER = "live-1.cloud-platform.service.justice.gov.uk"
    AWS_REGION = "eu-west-2"
    NAMEPACES_DIR = "namespaces/#{CLUSTER}"
    PRODUCTION_LABEL = "cloud-platform.justice.gov.uk/is-production"
    LABEL_TRUE = "true"
    EMPTY_MAIN_TF_URL = "https://raw.githubusercontent.com/ministryofjustice/cloud-platform-environments/master/namespace-resources/resources/main.tf"

    def initialize(args)
      @namespace = args.fetch(:namespace)
      @k8s_client = args.fetch(:k8s_client) { initialise_k8s_client }
      check_prerequisites
    end

    def delete
      if safe_to_delete?
        destroy_aws_resources
        delete_namespace
        clean_up
      end
    end

    private

    def check_prerequisites
      raise "No namespace supplied" if namespace.to_s.empty?

      %w[
        AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY
        KUBECONFIG_S3_BUCKET
        KUBECONFIG_S3_KEY
        KUBE_CONFIG
        KUBE_CTX
        PIPELINE_TERRAFORM_STATE_LOCK_TABLE
        PIPELINE_STATE_BUCKET
      ].each do |var|
        env(var)
      end
    end

    def safe_to_delete?
      dir = File.join(NAMEPACES_DIR, namespace)
      if FileTest.directory?(File.join(NAMEPACES_DIR, namespace))
        log("red", "Namespace folder #{dir} exists. Will not delete.")
        return false
      end

      ns = k8s_client.get_namespaces.find { |n| n.metadata.name == namespace }

      if ns.nil?
        log("red", "Namespace #{namespace} not found in #{CLUSTER}. Will not delete.")
        return false
      end

      if ns.metadata.labels[PRODUCTION_LABEL] == LABEL_TRUE
        log("red", "Namespace #{namespace} has 'is-production: true'. Will not delete.")
        return false
      end

      true
    end

    def destroy_aws_resources
      create_empty_main_tf
      log("green", "Destroying AWS resources for namespace #{namespace}...")
      NamespaceDir.new(cluster: CLUSTER, dir: namespace_dir).apply
    end

    def namespace_dir
      File.join(NAMEPACES_DIR, namespace)
    end

    def delete_namespace
      log("green", "Deleting namespace #{namespace}...")
      k8s_client.delete_namespace(namespace)
    end

    def initialise_k8s_client
      kubeconfig = {
        s3client: Aws::S3::Client.new(
          region: AWS_REGION,
          credentials: Aws::Credentials.new(
            env("AWS_ACCESS_KEY_ID"),
            env("AWS_SECRET_ACCESS_KEY")
          )
        ),
        bucket: env("KUBECONFIG_S3_BUCKET"),
        key: env("KUBECONFIG_S3_KEY"),
        local_target: env("KUBE_CONFIG"),
      }
      config_file = Kubeconfig.new(kubeconfig).fetch_and_store

      config = Kubeclient::Config.read(config_file)

      ctx = config.context(env("KUBE_CTX"))

      Kubeclient::Client.new(
        ctx.api_endpoint,
        "v1",
        ssl_options: ctx.ssl_options,
        auth_options: ctx.auth_options
      )
    end

    def create_empty_main_tf
      dir = File.join(namespace_dir, "resources")
      execute("mkdir -p #{dir}")
      content = URI.open(EMPTY_MAIN_TF_URL).read
      file = File.join(dir, "main.tf")
      File.open(file, "w") { |f| f.puts(content) }
    end

    # Remove the empty main.tf we created, along
    # with the containing namespace folder
    def clean_up
      execute("rm -rf #{namespace_dir}")
    end

    def env(var)
      ENV.fetch(var)
    end
  end
end
