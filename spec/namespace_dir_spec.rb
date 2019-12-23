require "spec_helper"

describe CpEnv::NamespaceDir do
  let(:namespace) { "mynamespace" }
  let(:dir) { "/namespaces/live1/#{namespace}" }
  let(:cluster) { "my-cluster" }
  let(:executor) { double(CpEnv::Executor) }
  let(:terraform) { double(CpEnv::Terraform) }
  let(:kubectl_apply) { "kubectl -n #{namespace} apply -f #{dir}" }
  let(:yaml_files) { [] }

  let(:params) { {
    dir: dir,
    cluster: cluster,
    executor: executor,
  } }

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
      allow(executor).to receive(:execute).with("git pull")
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
      let(:yaml_files) { [1,2,3] } # just has to be a non-empty array that responds to 'any?'

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

    context "with a gitops namespace" do
      it "applies kubernetes files"
      it "calls terraform apply"
      it "applies gitops kubernetes files"
    end
  end
end
