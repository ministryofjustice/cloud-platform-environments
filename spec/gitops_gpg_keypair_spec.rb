require "spec_helper"

describe GpgKeypair do
  subject(:keypair) { described_class.new }

  it "instantiates" do
    expect(keypair).to be_a(GpgKeypair)
  end

  specify { expect(keypair).to respond_to(:generate) }

  it "generates a keypair" do
    result = keypair.generate
    expect(result).to have_key(:public)
    expect(result).to have_key(:private)
  end
end
