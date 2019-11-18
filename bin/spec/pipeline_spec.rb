require "spec_helper"

describe "pipeline" do
  context "set_kube_context" do
  end

  context "apply_cluster_level_resources" do
  end

  context "all_namespace_dirs" do
  end

  context "apply_namespace_dir" do
  end

  context "changed_namespace_dirs" do

  end

  context "execute" do
    let(:cmd) { "ls" }
    let(:status) { double(success?: true) }

    it "executes and returns status" do
      expect(Open3).to receive(:capture3).with(cmd).and_return(["", "", status])
      allow($stdout).to receive(:puts).with("\e[34mexecuting: #{cmd}\e[0m")
      allow($stdout).to receive(:puts).with("")

      execute(cmd)
    end

    it "logs" do
      allow(Open3).to receive(:capture3).with(cmd).and_return(["", "", status])
      expect($stdout).to receive(:puts).with("\e[34mexecuting: #{cmd}\e[0m")
      expect($stdout).to receive(:puts).with("")

      execute(cmd)
    end

    context "on failure" do
      let(:status) { double(success?: false) }

      it "raises an error" do
        allow(Open3).to receive(:capture3).with(cmd).and_return(["", "", status])
        expect($stdout).to receive(:puts).with("\e[34mexecuting: #{cmd}\e[0m")
        expect($stdout).to receive(:puts).with("\e[31mCommand: #{cmd} failed.\e[0m")
        expect($stdout).to receive(:puts).with("")

        expect {
          execute(cmd)
        }.to raise_error(RuntimeError)
      end

      it "does not raise if can_fail is set" do
        allow(Open3).to receive(:capture3).with(cmd).and_return(["", "", status])
        expect($stdout).to receive(:puts).with("\e[34mexecuting: #{cmd}\e[0m")
        expect($stdout).to receive(:puts).with("")
        expect {
          execute(cmd, can_fail: true)
        }.to_not raise_error
      end
    end
  end

  context "log" do
    context "green" do
      let(:colour) { "green" }
      let(:message) { "green message" }

      specify {
        expect($stdout).to receive(:puts).with("\e[32m#{message}\e[0m")
        log(colour, message)
      }
    end

    context "blue" do
      let(:colour) { "blue" }
      let(:message) { "blue message" }

      specify {
        expect($stdout).to receive(:puts).with("\e[34m#{message}\e[0m")
        log(colour, message)
      }
    end

    context "red" do
      let(:colour) { "red" }
      let(:message) { "red message" }

      specify {
        expect($stdout).to receive(:puts).with("\e[31m#{message}\e[0m")
        log(colour, message)
      }
    end

    context "unknown colour" do
      let(:colour) { "puce" }
      let(:message) { "wibble" }

      specify {
        expect {
          log(colour, message)
        }.to raise_error(RuntimeError, "Unknown colour puce passed to 'log' method")
      }
    end

  end
end
