require "spec_helper"

describe CpEnv::NamespaceDir do
  let(:namespace) { "mynamespace" }
  let(:dir) { "/namespaces/live1/#{namespace}" }
  let(:cluster) { "my-cluster" }

  let(:success) { double(success?: true) }
  let(:resp) { ["stdout", "stderr", success] }
  let(:executor) { double(CpEnv::Executor, execute: resp) }

  let(:terraform) { double(CpEnv::Terraform) }
  let(:kubectl_apply) { "kubectl -n #{namespace} apply -f #{dir}" }
  let(:yaml_files) { [] }

  let(:params) {
    {
      dir: dir,
      cluster: cluster,
      executor: executor,
    }
  }

  subject(:namespace_dir) { described_class.new(params) }

  before do
    allow(CpEnv::Terraform).to receive(:new).and_return(terraform)
    allow(Dir).to receive(:glob).with("#{dir}/*.{yaml,yml,json}").and_return(yaml_files)
    allow($stdout).to receive(:puts)
  end

  context "when dir is not a directory path" do
    before do
      allow(FileTest).to receive(:directory?).with(dir).and_return(false)
    end

    it "does not update the working copy" do
      expect(executor).to_not receive(:execute).with("git pull")
      namespace_dir.apply
    end

    it "does not call terraform apply" do
      expect(terraform).to_not receive(:apply)
      namespace_dir.apply
    end
  end

  context "when given a directory" do
    before do
      allow(FileTest).to receive(:directory?).with(dir).and_return(true)
      allow(terraform).to receive(:apply)
    end

    it "updates the working copy" do
      expect(executor).to receive(:execute).with("git pull")
      namespace_dir.apply
    end

    it "calls terraform apply" do
      expect(terraform).to receive(:apply)
      namespace_dir.apply
    end

    context "with kubernetes files" do
      let(:yaml_files) { [1, 2, 3] } # just has to be a non-empty array that responds to 'any?'

      it "applies kubernetes files" do
        expect(executor).to receive(:execute).with(kubectl_apply)
        namespace_dir.apply
      end
    end

    context "with no kubernetes files" do
      let(:yaml_files) { [] } # just has to be a non-empty array that responds to 'any?'

      it "does not run kubectl apply" do
        expect(executor).to_not receive(:execute).with(kubectl_apply)
        namespace_dir.apply
      end
    end

    xcontext "with a gitops namespace" do
      let(:team_name) { "webops" }
      let(:kubectl_apply_gitops) { "kubectl -n concourse-#{team_name} apply -f #{dir}/gitops-resources" }
      let(:yaml) {
        <<~YAML
          subjects:
            - kind: Group
              name: "github:#{team_name}"
              apiGroup: rbac.authorization.k8s.io
        YAML
      }

      let(:keypair) { double(CpEnv::GitopsGpgKeypair, generate_and_store: nil) }

      before do
        allow(FileTest).to receive(:exists?).with("#{dir}/gitops-resources").and_return(true)
        allow(File).to receive(:read).with("#{dir}/01-rbac.yaml").and_return(yaml)
        allow(CpEnv::GitopsGpgKeypair).to receive(:new).and_return(keypair)
      end

      context "with kubernetes files" do
        let(:yaml_files) { [1, 2, 3] } # just has to be a non-empty array that responds to 'any?'

        it "applies kubernetes files" do
          expect(executor).to receive(:execute).with(kubectl_apply)
          namespace_dir.apply
        end

        it "calls terraform apply" do
          expect(terraform).to receive(:apply)
          namespace_dir.apply
        end

        it "applies gitops kubernetes files" do
          expect(executor).to receive(:execute).with(kubectl_apply_gitops)
          namespace_dir.apply
        end
      end
    end
  end
end
