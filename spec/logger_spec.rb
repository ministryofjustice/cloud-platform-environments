require "spec_helper"

describe CpEnv::Logger do
  subject(:logger) { described_class.new }

  context "colour coding" do
    specify "red" do
      expect($stdout).to receive(:puts).with("\e[31mwibble\e[0m")
      logger.log("red", "wibble")
    end

    specify "green" do
      expect($stdout).to receive(:puts).with("\e[32mwibble\e[0m")
      logger.log("green", "wibble")
    end

    specify "blue" do
      expect($stdout).to receive(:puts).with("\e[34mwibble\e[0m")
      logger.log("blue", "wibble")
    end

    it "barfs if colour is unknown" do
      expect {
        logger.log("nosuchcolour", "wibble")
      }.to raise_error(RuntimeError, "Unknown colour nosuchcolour passed to 'log' method")
    end
  end

  context "filtering" do
    CpEnv::Logger::FILTER_LIST.each do |keyword|
      it "redacts sensitive terms" do
        expect($stdout).to receive(:puts).with("\e[32mwibble #{keyword} REDACTED\e[0m")
        logger.log("green", "wibble #{keyword} whatever")
      end
    end
  end
end
