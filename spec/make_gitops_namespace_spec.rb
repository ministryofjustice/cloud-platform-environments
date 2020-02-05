require "spec_helper"

def make_gitops_namespace(filename)
  cmd = "./bin/create-gitops-namespace-files.rb #{filename}"
  system(cmd)
end

describe "make gitops namespace" do
  let(:answers_file) { "spec/fixtures/make-gitops-namespace-answers.yaml" }
  let(:namespace) { "make-gitops-namespace-test-dev" } # Defined in the answers_file
  let(:namespace_dir) { "namespaces/live-1.cloud-platform.service.justice.gov.uk/#{namespace}" }
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

  xit "creates env repo files with correct contents" do
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
