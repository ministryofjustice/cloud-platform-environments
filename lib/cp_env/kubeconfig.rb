class CpEnv
  class Kubeconfig
    attr_reader :s3client, :bucket, :key, :local_target

    def initialize(args)
      @s3client = args.fetch(:s3client)
      @bucket = args.fetch(:bucket)
      @key = args.fetch(:key)
      @local_target = args.fetch(:local_target)
    end

    def fetch_and_store
      config = s3client.get_object(bucket: bucket, key: key)
      File.open(local_target, "w") { |f| f.puts(config.body.read) }
      local_target
    end
  end
end
