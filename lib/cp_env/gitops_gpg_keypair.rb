class CpEnv
  class GitopsGpgKeypair
    attr_reader :namespace, :team_name
    attr_reader :executor, :key_generator

    def initialize(args)
      @namespace = args.fetch(:namespace)
      @team_name = args.fetch(:team_name)
      @executor = args.fetch(:executor) { CpEnv::Executor.new }
      @key_generator = args.fetch(:key_generator) { CpEnv::GpgKeypair.new }
    end

    def generate_and_store
      unless gpg_key_exists?(seckey_secret_name)
        delete_pubkey_secret
        pubkey, seckey = generate_keypair
        store_in_namespace_secrets(pubkey: pubkey, seckey: seckey)
      end
    end

    private

    def gpg_key_exists?(gpg_key_name)
      stdout, _, _ = executor.execute("kubectl -n #{namespace} get secrets -o json", silent: true)
      names = JSON.parse(stdout)["items"].map { |i| i.dig("metadata", "name") }
      names.include?(gpg_key_name)
    end

    def delete_pubkey_secret
      log("blue", "Unable to find secret gpg key, removing leftover public keys.")
      if gpg_key_exists?(pubkey_secret_name)
        executor.execute("kubectl -n #{namespace} delete secret #{pubkey_secret_name}")
      end
    end

    def pubkey_secret_name
      "#{team_name}-gpg-pubkey"
    end

    def seckey_secret_name
      "#{team_name}-gpg-seckey"
    end

    def generate_keypair
      hash = key_generator.generate

      [
        Base64.strict_encode64(hash.fetch(:public)),
        Base64.strict_encode64(hash.fetch(:private)),
      ]
    end

    def store_in_namespace_secrets(args)
      pubkey = args.fetch(:pubkey)
      seckey = args.fetch(:seckey)

      create_secret(
        namespace: namespace,
        secret_name: pubkey_secret_name,
        data: pubkey,
      )

      create_secret(
        namespace: namespace,
        secret_name: seckey_secret_name,
        data: seckey,
      )
    end

    def create_secret(args)
      name = args.fetch(:secret_name)
      namespace = args.fetch(:namespace)

      json = <<~EOF
        {
          "apiVersion": "v1",
          "kind": "Secret",
          "metadata": {
            "name": "#{name}",
            "namespace": "#{namespace}"
          },
          "data": {
            "key": "#{args.fetch(:data)}"
          }
        }
      EOF

      _, stderr, status = executor.execute("echo '#{json}' | kubectl -n #{args.fetch(:namespace)} apply -f - ", silent: true)
      raise "Failed to create secret #{name} in namespace #{namespace}\n#{stderr}" unless status.success?
      puts "secret #{name} created in namespace #{namespace}"
    end
  end
end
