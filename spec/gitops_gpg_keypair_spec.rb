require "spec_helper"

xdescribe CpEnv::GitopsGpgKeypair do
  let(:executor) { double(CpEnv::Executor) }
  let(:key_generator) { double(CpEnv::GpgKeypair) }
  let(:success) { double(success?: true) }

  let(:keypair) {
    {
      public: "pubkey",
      private: "privkey",
    }
  }

  let(:pubkey64) { "cHVia2V5" } # Base64.encode64("pubkey").strip
  let(:privkey64) { "cHJpdmtleQ==" } # Base64.encode64("privkey").strip

  let(:team_name) { "my-team" }
  let(:namespace) { "my-namespace" }

  let(:sec_response) { [%({ "items": [ { "metadata": { "name": "#{sec_key_name}" } } ] }), "stderr", success] }
  let(:pub_response) { [%({ "items": [ { "metadata": { "name": "#{pub_key_name}" } } ] }), "stderr", success] }

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
    allow($stdout).to receive(:puts)
  end

  context "when secret key does not exist" do
    let(:sec_key_name) { "wibble" }

    it "generates a keypair" do
      allow(executor).to receive(:execute).and_return(sec_response)

      expect(key_generator).to receive(:generate).and_return(keypair)

      gpg.generate_and_store
    end

    it "stores public key in app namespace" do
      allow(executor).to receive(:execute).and_return(sec_response)
      allow(key_generator).to receive(:generate).and_return(keypair)

      gpg.generate_and_store

      expect(executor).to have_received(:execute).with(/pubkey.*kubectl -n my-namespace apply/m, silent: true) do |args|
        expect(args).to match /"kind": "Secret"/
        expect(args).to match /"namespace": "#{namespace}"/
        expect(args).to match /"name": "#{team_name}-gpg-pubkey"/
        expect(args).to match /"key": "#{pubkey64}"/
        expect(args).to match /kubectl -n #{namespace} apply -f -/
      end
    end

    it "stores public key in concourse team namespace" do
      allow(executor).to receive(:execute).and_return(sec_response)
      allow(key_generator).to receive(:generate).and_return(keypair)

      gpg.generate_and_store

      expect(executor).to have_received(:execute).with(/pubkey.*kubectl -n concourse-my-team apply/m, silent: true) do |args|
        expect(args).to match /"kind": "Secret"/
        expect(args).to match /"namespace": "concourse-#{team_name}"/
        expect(args).to match /"name": "#{team_name}-gpg-pubkey"/
        expect(args).to match /"key": "#{pubkey64}"/
        expect(args).to match /kubectl -n concourse-#{team_name} apply -f -/
      end
    end

    it "stores private key in concourse team namespace" do
      allow(executor).to receive(:execute).and_return(sec_response)
      allow(key_generator).to receive(:generate).and_return(keypair)

      gpg.generate_and_store

      expect(executor).to have_received(:execute).with(/seckey.*kubectl -n concourse-my-team apply/m, silent: true) do |args|
        expect(args).to match /"kind": "Secret"/
        expect(args).to match /"namespace": "concourse-#{team_name}"/
        expect(args).to match /"name": "#{team_name}-gpg-seckey"/
        expect(args).to match /"key": "#{privkey64}"/
        expect(args).to match /kubectl -n concourse-#{team_name} apply -f -/
      end
    end
  end

  context "when secret key exists" do
    let(:sec_key_name) { "#{team_name}-gpg-seckey" }

    it "does not generate a keypair" do
      allow(executor).to receive(:execute).and_return(sec_response)

      expect(key_generator).to_not receive(:generate)

      gpg.generate_and_store
    end

    context "when public key does not exist in app namespace" do
      let(:pub_key_name) { "does-not-match" }

      it "copies public key from concourse-team namespace" do
        allow(executor).to receive(:execute).and_return(
          sec_response,
          pub_response,
        )

        cmd = "kubectl -n concourse-#{team_name} get secrets #{team_name}-gpg-pubkey -o yaml | sed 's/namespace: concourse-#{team_name}/namespace: #{namespace}/'  | kubectl create -f -"

        expect(executor).to receive(:execute).with(cmd, silent: true)

        gpg.generate_and_store
      end
    end

    context "when public key exists in app namespace" do
      let(:pub_key_name) { "#{team_name}-gpg-pubkey" }

      it "does not copy the public key from the concourse-team namespace" do
        allow(executor).to receive(:execute).and_return(
          sec_response,
          pub_response,
        )

        cmd = "kubectl -n concourse-#{team_name} get secrets #{team_name}-gpg-pubkey -o yaml | sed 's/namespace: concourse-#{team_name}/namespace: #{namespace}/'  | kubectl create -f -"

        expect(executor).to_not receive(:execute).with(cmd, silent: true)

        gpg.generate_and_store
      end
    end
  end
end
