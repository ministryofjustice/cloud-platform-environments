require "spec_helper"

describe CpEnv::GitopsGpgKeypair do
  let(:params) { {
    namespace: "my-namespace",
    team_name: "my-team",
  } }

  subject(:gpg) { described_class.new(params) }

  it "instantiates" do
    expect(gpg).to be_a(CpEnv::GitopsGpgKeypair)
  end

  specify { expect(gpg).to respond_to(:generate_and_store) }
end
