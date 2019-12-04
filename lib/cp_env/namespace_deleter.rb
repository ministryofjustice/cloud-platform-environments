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

    attr_reader :namespace, :k8sclient

    CLUSTER = "live-1.cloud-platform.service.justice.gov.uk"
    KUBECONFIG_AWS_REGION = "eu-west-2"
    NAMEPACES_DIR = "namespaces/#{CLUSTER}"
    PRODUCTION_LABEL = "cloud-platform.justice.gov.uk/is-production"
    LABEL_TRUE = "true"
    EMPTY_MAIN_TF_URL = "https://raw.githubusercontent.com/ministryofjustice/cloud-platform-environments/master/namespace-resources/resources/main.tf"

    def initialize(args)
      @namespace= args.fetch(:namespace)
      # check_prerequisites
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

      %w(
        KUBECONFIG_AWS_ACCESS_KEY_ID
        KUBECONFIG_AWS_SECRET_ACCESS_KEY
        KUBECONFIG_S3_BUCKET
        KUBECONFIG_S3_KEY
        KUBE_CONFIG
        KUBE_CTX
        PIPELINE_TERRAFORM_STATE_LOCK_TABLE
        PIPELINE_STATE_BUCKET
      ).each do |var|
        env(var)
      end
    end

    def safe_to_delete?
      dir = File.join(NAMEPACES_DIR, namespace)
      if FileTest.directory?(File.join(NAMEPACES_DIR, namespace))
        log("red", "Namespace folder #{dir} exists. Will not delete.")
        return false
      end

      ns = kubeclient.get_namespaces.find { |n| n.metadata.name == namespace }

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
      apply_namespace_dir(CLUSTER, namespace_dir)
    end

    def namespace_dir
      File.join(NAMEPACES_DIR, namespace)
    end

    def delete_namespace
      log("green", "Deleting namespace #{namespace}...")
      kubeclient.delete_namespace(namespace)
    end

    def kubeclient
      if @k8s_client.nil?
        kubeconfig = {
          s3client: Aws::S3::Client.new(
            region: KUBECONFIG_AWS_REGION,
            credentials: Aws::Credentials.new(
              env('KUBECONFIG_AWS_ACCESS_KEY_ID'),
              env('KUBECONFIG_AWS_SECRET_ACCESS_KEY')
            )
          ),
          bucket:       env('KUBECONFIG_S3_BUCKET'),
          key:          env('KUBECONFIG_S3_KEY'),
          local_target: env('KUBE_CONFIG'),
        }
        config_file = Kubeconfig.new(kubeconfig).fetch_and_store

        config = Kubeclient::Config.read(config_file)

        ctx = config.context(env('KUBE_CTX'))

        @k8s_client = Kubeclient::Client.new(
          ctx.api_endpoint,
          "v1",
          ssl_options: ctx.ssl_options,
          auth_options: ctx.auth_options
        )
      end

      @k8s_client
    end

    def create_empty_main_tf
      dir = File.join(namespace_dir, "resources")
      execute("mkdir -p #{dir}")
      content = URI::open(EMPTY_MAIN_TF_URL).read
      file = File.join(dir, "main.tf")
      File.open(file, 'w') { |f| f.puts(content) }
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
