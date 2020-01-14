require "spec_helper"

xdescribe CpEnv::GpgKeypair do
  subject(:keypair) { described_class.new }

  it "instantiates" do
    expect(keypair).to be_a(CpEnv::GpgKeypair)
  end

  it "generates a keypair" do
    result = keypair.generate
    expect(result).to have_key(:public)
    expect(result).to have_key(:private)
  end
end
