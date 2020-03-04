require "spec_helper"

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

  describe "plan" do
    it "runs terraform plan" do
      env_vars.each do |key, val|
        expect(ENV).to receive(:fetch).with(key).at_least(:once).and_return(val)
      end
      allow(FileTest).to receive(:directory?).and_return(true)

      tf_dir = "#{dir}/resources"

      tf_init = "cd #{tf_dir}; terraform init -backend-config=\"bucket=bucket\" -backend-config=\"key=key-prefix/live-1.cloud-platform.service.justice.gov.uk/mynamespace/terraform.tfstate\" -backend-config=\"dynamodb_table=lock-table\" -backend-config=\"region=region\""

      tf_plan = "cd #{tf_dir}; terraform plan   | grep -v password"

      expect_execute(tf_init, "", success)
      expect_execute(tf_plan, "", success)
      expect($stdout).to receive(:puts)

      tf.plan
    end
  end

  describe "apply" do
    it "applies terraform files" do
      env_vars.each do |key, val|
        expect(ENV).to receive(:fetch).with(key).at_least(:once).and_return(val)
      end
      allow(FileTest).to receive(:directory?).and_return(true)
      tf_dir = "#{dir}/resources"
      tf_init = "cd #{tf_dir}; terraform init -backend-config=\"bucket=bucket\" -backend-config=\"key=key-prefix/live-1.cloud-platform.service.justice.gov.uk/mynamespace/terraform.tfstate\" -backend-config=\"dynamodb_table=lock-table\" -backend-config=\"region=region\""

      tf_apply = "cd #{tf_dir}; terraform apply -auto-approve | grep -v password"

      expect_execute(tf_init, "", success)
      expect_execute(tf_apply, "", success)
      expect($stdout).to receive(:puts)

      tf.apply
    end
  end
end
