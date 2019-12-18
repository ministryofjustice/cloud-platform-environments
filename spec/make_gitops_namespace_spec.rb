require "spec_helper"

def make_gitops_namespace(filename)
  cmd = "./bin/create-gitops-namespace-files.rb #{filename}"
  system(cmd)
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

  it "creates all the namespace files" do
    make_gitops_namespace(answers_file)

    fixture_files = Dir["#{fixture_dir}/**/*"].map { |f| f.sub(fixture_dir, "") }
    created_files = Dir["#{namespace_dir}/**/*"].map { |f| f.sub(namespace_dir, "") }

    expect(created_files).to eq(fixture_files)
  end

  it "creates env repo files with correct contents" do
    make_gitops_namespace(answers_file)

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

  it "create deployment directory" do
    expect {
      make_gitops_namespace(answers_file)
    }.to change { FileTest.directory?(deploy_dir) }.from(false).to(true)
  end

  it "create deployment files" do
    make_gitops_namespace(answers_file)
    fixture_files = Dir["#{fixture_deploy_dir}/**/*"].map { |f| f.sub(fixture_deploy_dir, "") }
    created_files = Dir["#{deploy_dir}/**/*"].map { |f| f.sub(deploy_dir, "") }

    expect(created_files).to eq(fixture_files)
  end

  it "create deployment files with correct contents" do
    make_gitops_namespace(answers_file)

    files = Dir["#{fixture_deploy_dir}/**/*"].map { |f| f.sub(fixture_deploy_dir, "") }

    files.each do |file|
      fixture_file = File.join(fixture_deploy_dir, file)
      deploy_file = File.join(deploy_dir, file)

      unless FileTest.directory?(fixture_file)
        fixture = File.read(fixture_file)
        deploy = File.read(deploy_file)

        expect(fixture).to eq(deploy)
      end
    end
  end
end
