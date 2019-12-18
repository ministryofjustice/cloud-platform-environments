require "spec_helper"

def make_gitops_namespace(filename)
  cmd = "./bin/create-gitops-namespace-files.rb #{filename}"
  system(cmd)
end

def expect_same_files(expected_dir, actual_dir)
  expected_files = Dir["#{expected_dir}/**/*"].map { |f| f.sub(expected_dir, "") }
  actual_files = Dir["#{actual_dir}/**/*"].map { |f| f.sub(actual_dir, "") }

  expect(expected_files).to eq(actual_files)
end

def expect_directories_to_match(expected_dir, actual_dir)
  expect_same_files(fixture_deploy_dir, deploy_dir)

  expected_files = Dir["#{expected_dir}/**/*"].map { |f| f.sub(expected_dir, "") }

  expected_files.each do |file|
    expected_file = File.join(expected_dir, file)
    actual_file = File.join(actual_dir, file)

    unless FileTest.directory?(expected_file)
      expected = File.read(expected_file)
      actual = File.read(actual_file)

      expect(expected).to eq(actual)
    end
  end
end

describe "make gitops namespace" do
  let(:answers_file) { "spec/fixtures/make-gitops-namespace-answers.yaml" }
  let(:namespace) { "make-gitops-namespace-test-dev" } # Defined in the answers_file
  let(:namespace_dir) { "namespaces/gitops-test.cloud-platform.service.justice.gov.uk/#{namespace}" }
  let(:fixture_dir) { "spec/fixtures/make-gitops-namespace-test-dev" }

  let(:fixture_dir) { "spec/fixtures/make-gitops-namespace-test-dev" }

  let(:deploy_dir) { "/tmp/cloud-platform-deploy/#{namespace}" }
  let(:fixture_deploy_dir) { "spec/fixtures/gitops-deploy-files" }

  after do
    system("rm -rf #{namespace_dir}")
    system("rm -rf #{deploy_dir}")
  end

  it "creates namespace directory" do
    expect {
      make_gitops_namespace(answers_file)
    }.to change { FileTest.directory?(namespace_dir) }.from(false).to(true)
  end

  it "creates env repo files with correct contents" do
    make_gitops_namespace(answers_file)
    expect_directories_to_match(fixture_dir, namespace_dir)
  end

  it "create deployment directory" do
    expect {
      make_gitops_namespace(answers_file)
    }.to change { FileTest.directory?(deploy_dir) }.from(false).to(true)
  end

  it "creates deployment files with correct contents" do
    make_gitops_namespace(answers_file)
    expect_directories_to_match(fixture_deploy_dir, deploy_dir)
  end
end
