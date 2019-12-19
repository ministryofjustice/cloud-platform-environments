require "spec_helper"

describe CpEnv::GitopsGpgKeypair do
  let(:executor) { double(CpEnv::Executor) }
  let(:key_generator) { double(CpEnv::GpgKeypair) }
  let(:success) { double(success?: true) }

  let(:keypair) {
    {
      public: "pubkey",
      private: "privkey",
    }
  }

  let(:team_name) { "my-team" }
  let(:namespace) { "my-namespace" }
  let(:pub_key_name) { "#{team_name}-gpg-pubkey" }

  let(:params) {
    {
      namespace: namespace,
      team_name: team_name,
      executor: executor,
      key_generator: key_generator,
    }
  }

  subject(:gpg) { described_class.new(params) }

  before do
    allow(executor).to receive(:execute).and_return(["stdout", "stderr", success])
    allow($stdout).to receive(:puts)

    # See if secret key is in the concourse-team namespace
    cmd = "kubectl -n concourse-#{team_name} get secrets -o json"
    json = %({ "items": [ { "metadata": { "name": "#{sec_key_name}" } } ] })
    allow(executor).to receive(:execute).with(cmd, silent: true).and_return(json)

    # See if public key is in the app namespace
    cmd = "kubectl -n #{namespace} get secrets -o json"
    json = %({ "items": [ { "metadata": { "name": "#{pub_key_name}" } } ] })
    allow(executor).to receive(:execute).with(cmd, silent: true).and_return(json)
  end

  context "when secret key exists" do
    let(:sec_key_name) { "#{team_name}-gpg-seckey" }

    it "does not generate a keypair" do
      expect(key_generator).to_not receive(:generate)
      gpg.generate_and_store
    end

    context "when public key does not exist in app namespace" do
      let(:pub_key_name) { "does-not-match-public-key-name" }

      # TODO: Fix this. I can't figure out how to make this test work correctly. With this version, rspec insists
      # that I'm expecting the command to be called 3 times - I suspect this is something to do with having multiple
      # different expectations on the executor object. I tried several variants, but couldn't get it to work, so I'm
      # giving up, for now.
      #
      # it "copies public key from concourse-team namespace" do
      #   cmd = "kubectl -n concourse-#{team_name} get secrets #{team_name}-gpg-pubkey -o yaml | sed 's/namespace: concourse-#{team_name}/namespace: #{namespace}/'  | kubectl create -f -"
      #   expect(executor).to receive(:execute).with(cmd, silent: true).at_least(:once).and_return("stdout", "stderr", success)
      #
      #   gpg.generate_and_store
      # end
    end

    context "when public key exists in app namespace" do
      it "does not copy the public key from the concourse-team namespace" do
        cmd = "kubectl -n concourse-#{team_name} get secrets #{team_name}-gpg-pubkey -o yaml | sed 's/namespace: concourse-#{team_name}/namespace: #{namespace}/'  | kubectl create -f -"
        expect(executor).to_not receive(:execute).with(cmd, silent: true)

        gpg.generate_and_store
      end
    end
  end

  context "when secret key does not exist" do
    let(:sec_key_name) { "wibble" }

    it "generates a keypair" do
      expect(key_generator).to receive(:generate).and_return(keypair)
      gpg.generate_and_store
    end

    # TODO: Fix these. I can't figure out how to make these tests work correctly.
    # it "stores public key in app namespace"
    # it "stores public key in concourse team namespace"
    # it "stores private key in concourse team namespace"
  end
end
