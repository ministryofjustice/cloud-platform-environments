require "spec_helper"

describe CpEnv::GpgKeypair do
  subject(:keypair) { described_class.new }

  xit "instantiates" do
    expect(keypair).to be_a(CpEnv::GpgKeypair)
  end

  xit "generates a keypair" do
    result = keypair.generate
    expect(result).to have_key(:public)
    expect(result).to have_key(:private)
  end
end
