require "spec_helper"

def make_namespace(filename)
  # cmd = "ANSWERS_FILE=#{filename} make namespace > /dev/null"
  cmd = "ANSWERS_FILE=#{filename} make namespace"
  system(cmd)
end

describe "make namespace" do
  let(:answers_file) { "spec/fixtures/make-namespace-answers.yaml" }
  let(:namespace) { "make-namespace-test-dev" } # Defined in the answers_file
  let(:namespace_dir) { "namespaces/live-1.cloud-platform.service.justice.gov.uk/#{namespace}" }
  let(:fixture_dir) { "spec/fixtures/make-namespace-test-dev" }

  let(:fixture_dir) { "spec/fixtures/make-namespace-test-dev" }

  after do
    system("rm -rf #{namespace_dir}")
  end

  it "creates namespace directory" do
    expect {
      make_namespace(answers_file)
    }.to change { FileTest.directory?(namespace_dir) }.from(false).to(true)
  end

  it "creates all the namespace files" do
    make_namespace(answers_file)

    fixture_files = Dir["#{fixture_dir}/**/*"].map { |f| f.sub(fixture_dir, "") }
    created_files = Dir["#{namespace_dir}/**/*"].map { |f| f.sub(namespace_dir, "") }

    expect(created_files).to eq(fixture_files)
  end

  it "creates files with correct contents" do
    make_namespace(answers_file)

    files = Dir["#{fixture_dir}/**/*"].map { |f| f.sub(fixture_dir, "") }

    files.each do |file|
      fixture_file = File.join(fixture_dir, file)
      namespace_file = File.join(namespace_dir, file)

      unless FileTest.directory?(fixture_file)
        fixture = File.read(fixture_file)
        namespace = File.read(namespace_file)

        expect(fixture).to eq(namespace)
      end
    end
  end
end
