class CpEnv
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

    def tf_init
      key = "#{key_prefix}#{cluster}/#{namespace}/terraform.tfstate"

      cmd = [
        %(terraform init),
        %(-backend-config="bucket=#{bucket}"),
        %(-backend-config="key=#{key}"),
        %(-backend-config="dynamodb_table=#{lock_table}"),
        %(-backend-config="region=#{region}")
      ].join(" ")

      execute("cd #{tf_dir}; #{cmd}")
    end

    def tf_apply
      cmd = tf_cmd(
        operation: "apply",
        last: %(-auto-approve)
      )

      execute("cd #{tf_dir}; #{cmd} | grep -v password")
    end

    def tf_plan
      cmd = tf_cmd(
        operation: "plan",
        last: " "
      )

      execute("cd #{tf_dir}; #{cmd} | grep -v password")
    end

    def tf_dir
      File.join(dir, "resources")
    end

    def tf_cmd(opts)
      operation = opts.fetch(:operation)
      last = opts.fetch(:last)

      "terraform #{operation} #{last}"
    end
  end
end
