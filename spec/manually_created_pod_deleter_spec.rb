require "spec_helper"

describe CpEnv::ManuallyCreatedPodDeleter do
  let(:executor) { double(CpEnv::Executor) }
  let(:params) { {
    executor: executor
  } }
  subject(:deleter) { described_class.new(params) }

  let(:json) { %[{"items": []}] }

  before do
    allow(executor).to receive(:execute).with("kubectl get pods --all-namespaces -o json", silent: true).and_return(json)
  end

  it "gets all pods" do
    expect(executor).to receive(:execute).with("kubectl get pods --all-namespaces -o json", silent: true).and_return(json)
    deleter.run
  end

  context "when there are pods" do
    let(:namespace) { "mynamespace" }
    let(:startTime) { (Date.today - 3).to_s }

    let(:pod) {
      %[
         {
           "metadata": {
             "name": "mypod",
             "namespace": "#{namespace}"
           },
           "status": {
             "startTime": "#{startTime}"
           }
         }
       ]
    }

    let(:json) { %[{"items": [ #{pod} ]}] }

    context  "but the pod is 1 day old" do
      let(:startTime) { (Date.today - 1).to_s }

      it "does not delete the pod" do
        expect(executor).to_not receive(:execute).with("kubectl -n mynamespace delete pod mypod")
        deleter.run
      end
    end

    context "and the pod is 3 days old" do
      let(:startTime) { (Date.today - 3).to_s }

      it "deletes pod" do
        expect(executor).to receive(:execute).with("kubectl -n mynamespace delete pod mypod")
        deleter.run
      end

      context "but the pod is in kube-system" do
        let(:namespace) { "kube-system" }

        it "does not delete the pod" do
          expect(executor).to_not receive(:execute).with("kubectl -n mynamespace delete pod mypod")
          deleter.run
        end
      end
    end
  end
end
