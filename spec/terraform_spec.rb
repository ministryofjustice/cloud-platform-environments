require "spec_helper"
require 'tempfile'

describe CpEnv::Terraform do
  let(:cluster) { "live-1.cloud-platform.service.justice.gov.uk" }
  let(:namespace) { "mynamespace" }
  let(:dir) { "namespaces/#{cluster}/#{namespace}" }
  let(:success) { double(success?: true) }
  let(:failure) { double(success?: false) }

  let(:env_vars) {
    {
      "PIPELINE_STATE_BUCKET" => "bucket",
      "PIPELINE_STATE_KEY_PREFIX" => "key-prefix/",
      "PIPELINE_TERRAFORM_STATE_LOCK_TABLE" => "lock-table",
      "PIPELINE_STATE_REGION" => "region",
      "TF_VAR_cluster_name" => cluster,
      "TF_VAR_cluster_state_bucket" => "cloud-platform-terraform-state",
      "TF_VAR_cluster_state_key" => "cloud-platform/live-1/terraform.tfstate"
    }
  }

  let(:params) {
    {
      cluster: cluster,
      namespace: namespace,
      dir: dir
    }
  }

  

  subject(:tf) { described_class.new(params) }
  context "terraform 0.12" do
    let(:version_file) { "#{dir}/resources/versions.tf" }
    let(:content) {
      "terraform {
        required_version = \">= 0.12\"
      }"
    }

    def set_tfbinary(exists, status)
      allow(File).to receive(:exists?).and_return(exists)
      allow(File).to receive(:read).and_return(content)
      allow_any_instance_of(version_file).to receive(:status).and_return(status)
    end

    it "runs terraform plan" do
      env_vars.each do |key, val|
        expect(ENV).to receive(:fetch).with(key).at_least(:once).and_return(val)
      end
      allow(FileTest).to receive(:directory?).and_return(true)
      set_tfbinary(true,"terraform0.12")

      tf_dir = "#{dir}/resources"

      terraform_executable = "terraform12"
      tf_init = "cd #{tf_dir}; terraform12 init -backend-config=\"bucket=bucket\" -backend-config=\"key=key-prefix/live-1.cloud-platform.service.justice.gov.uk/mynamespace/terraform.tfstate\" -backend-config=\"dynamodb_table=lock-table\" -backend-config=\"region=region\""

      tf_plan = "cd #{tf_dir}; terraform12 plan  | grep -vE '^(\\x1b\\[0m)?\\s{3,}'"


      expect_execute(terraform_executable, "", success)
      expect_execute(tf_init, "", success)
      expect_execute(tf_plan, "", success)
      expect($stdout).to receive(:puts).at_least(:once)

      tf.plan
    end

    it "applies terraform files" do
      env_vars.each do |key, val|
        expect(ENV).to receive(:fetch).with(key).at_least(:once).and_return(val)
      end
      allow(FileTest).to receive(:directory?).and_return(true)
      tf_dir = "#{dir}/resources"
      tf_init = "cd #{tf_dir}; terraform12 init -backend-config=\"bucket=bucket\" -backend-config=\"key=key-prefix/live-1.cloud-platform.service.justice.gov.uk/mynamespace/terraform.tfstate\" -backend-config=\"dynamodb_table=lock-table\" -backend-config=\"region=region\""

      tf_apply = "cd #{tf_dir}; terraform12 apply -auto-approve"

      expect_execute(tf_init, "", success)
      expect_execute(tf_apply, "", success)
      expect($stdout).to receive(:puts).at_least(:once)

      tf.apply
    end

end

# context "terraform 0.13" do
#   before do
#     allow(FileTest).to receive(:exists?).with("#{dir}/resources/versions.tf").and_return(true)
#     allow(FileTest).to receive(:write).with("required_version = \">= 0.13\"").and_return(true)
#   end

#   describe "plan" do
#     # it "should create 'filename' and put 'required_version  in it" do
#     #   FilTest.should_receive(:open).with("versions.tf", "w").and_yield(file)
#     #   FileTest.should_receive(:write).with("required_version = \">= 0.12\"")
#     #   tf_executable = terraform0.13
#     #   expect_execute(tf_executable, "", success)
#     #   tf.terraform_executable
#     # end

#     it "runs terraform plan" do
#       env_vars.each do |key, val|
#         expect(ENV).to receive(:fetch).with(key).at_least(:once).and_return(val)
#       end
#       allow(FileTest).to receive(:directory?).and_return(true)

#       tf_dir = "#{dir}/resources"

#       tf_init = "cd #{tf_dir}; terraform13 init -backend-config=\"bucket=bucket\" -backend-config=\"key=key-prefix/live-1.cloud-platform.service.justice.gov.uk/mynamespace/terraform.tfstate\" -backend-config=\"dynamodb_table=lock-table\" -backend-config=\"region=region\""

#       tf_plan = "cd #{tf_dir}; terraform13 plan  "

#       expect_execute(tf_init, "", success)
#       expect_execute(tf_plan, "", success)
#       expect($stdout).to receive(:puts).at_least(:once)

#       tf.plan
#     end
#   end

#   describe "apply" do
#     it "applies terraform files" do
#       env_vars.each do |key, val|
#         expect(ENV).to receive(:fetch).with(key).at_least(:once).and_return(val)
#       end
#       allow(FileTest).to receive(:directory?).and_return(true)
#       tf_dir = "#{dir}/resources"
#       tf_init = "cd #{tf_dir}; terraform13 init -backend-config=\"bucket=bucket\" -backend-config=\"key=key-prefix/live-1.cloud-platform.service.justice.gov.uk/mynamespace/terraform.tfstate\" -backend-config=\"dynamodb_table=lock-table\" -backend-config=\"region=region\""

#       tf_apply = "cd #{tf_dir}; terraform13 apply -auto-approve"

#       expect_execute(tf_init, "", success)
#       expect_execute(tf_apply, "", success)
#       expect($stdout).to receive(:puts).at_least(:once)

#       tf.apply
#     end
#   end

# end
end
