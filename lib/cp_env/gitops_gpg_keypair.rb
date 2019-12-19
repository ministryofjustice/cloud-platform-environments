require 'base64'
require 'json'

class CpEnv
  class GitopsGpgKeypair
    attr_reader :namespace, :team_name

    def initialize(args)
      @namespace = args.fetch(:namespace)
      @team_name = args.fetch(:team_name)
    end

    def generate_and_store
      if secret_key_exists?
        copy_public_key
      else
        pubkey, seckey = generate_keypair
        store_in_namespace_secrets(pubkey: pubkey, seckey: seckey)
      end
    end

    private

    def copy_public_key
      unless public_key_exists?
        execute("kubectl -n concourse-#{team_name} get secrets #{pubkey_secret_name} -o yaml | sed 's/namespace: concourse-#{team_name}/namespace: #{namespace}/'  | kubectl create -f -", silent: true)
      end
    end

    def public_key_exists?
     stdout, _, _ = execute("kubectl -n #{namespace} get secrets -o json", silent: true)
     names = JSON.parse(stdout)["items"].map {|i| i.dig("metadata", "name")}
     names.include?(pubkey_secret_name)
    end

    def secret_key_exists?
     stdout, _, _ = execute("kubectl -n concourse-#{team_name} get secrets -o json", silent: true)
     names = JSON.parse(stdout)["items"].map {|i| i.dig("metadata", "name")}
     names.include?(seckey_secret_name)
    end

    def pubkey_secret_name
     "#{team_name}-gpg-pubkey"
    end

    def seckey_secret_name
      "#{team_name}-gpg-seckey"
    end

    def generate_keypair
      hash = GpgKeypair.new.generate

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
        namespace: "concourse-#{team_name}",
        secret_name: pubkey_secret_name,
        data: pubkey,
      )

      create_secret(
        namespace: "concourse-#{team_name}",
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

      _, stderr, status = execute("echo '#{json}' | kubectl -n #{args.fetch(:namespace)} apply -f - ", silent: true)
      raise "Failed to create secret #{name} in namespace #{namespace}\n#{stderr}" unless status.success?
      puts "secret #{name} created in namespace #{namespace}"
    end
  end
end
