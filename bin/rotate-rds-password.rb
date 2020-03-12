#!/usr/bin/env ruby

# Script to taint and recreate the password for an RDS instance, and then
# slowly delete all pods in the corresponding namespace to allow new pods to be
# created, which will pick up the new DB password from the kubernetes secret.
#
# In testing, this caused no downtime on the single application we looked at,
# because DB connections opened with the old, tainted password are still valid
# and usable after the password itself has been changed.
#
# It is possible that applications might experience downtime if, for example, a
# pod which was launched with the old password drops a DB connection and tries
# to open a new one (which will fail, because the password is no longer valid).
# Similarly, a pod launched with the old password (e.g. a cron job), which then
# waits to open a DB connection will fail to connect if the password has been
# replaced since the pod was launched. In the case of cron jobs, these pods
# should just fail and be relaunched successfully.

REQUIRED_ENV_VARS = %w[AWS_PROFILE TF_VAR_cluster_name TF_VAR_cluster_state_bucket TF_VAR_cluster_state_key]
REQUIRED_EXECUTABLES = %w[terraform kubectl cut grep which]
REQUIRED_AWS_PROFILES = %w[moj-cp]

CLUSTER = "live-1.cloud-platform.service.justice.gov.uk"

TF_STATE_REGION = "eu-west-1"
TF_STATE_BUCKET = "cloud-platform-terraform-state"
TF_STATE_LOCK_TABLE = "cloud-platform-environments-terraform-lock"

def main(namespace, rds_name)
  check_prerequisites(namespace, rds_name)
  replace_credentials(namespace, rds_name)
  replace_pods(namespace)
end

def replace_credentials(namespace, rds_name)
  tfinit(namespace)
  taint_rds_password(namespace, rds_name)
  system "cd #{tfdir(namespace)}; terraform apply -auto-approve"
end

# When replacing pods, it's worth going slowly. Any open connection to the db
# whose password we rotated will still work fine until it is dropped. So as
# long as we leave enough time for a new pod to become ready, using the new
# password, before we kill the next one, we should be able to replace all the
# pods with no application downtime.
def replace_pods(namespace, delay = 90)
  get_pods(namespace).each do |pod|
    system "kubectl -n #{namespace} delete pod #{pod}"
    sleep delay # This could be optimised, because there's no need to sleep after deleting the last pod
  end
end

def get_pods(namespace)
  cmd = %(kubectl -n #{namespace} get pods | grep Running | cut -f 1 -d' ')
  `#{cmd}`.split("\n")
end

# e.g. for rds_name = cccd_rds, we taint "module.cccd_rds.random_string.password"
def taint_rds_password(namespace, rds_name)
  target = "module.#{rds_name}.random_string.password"
  system "cd #{tfdir(namespace)}; terraform taint #{target}"
end

def tfinit(namespace)
  tfinit = [
    %(terraform init),
    %(-backend-config="bucket=#{TF_STATE_BUCKET}"),
    %(-backend-config="key=cloud-platform-environments/#{CLUSTER}/#{namespace}/terraform.tfstate"),
    %(-backend-config="region=#{TF_STATE_REGION}"),
    %(-backend-config="dynamodb_table=#{TF_STATE_LOCK_TABLE}")
  ].join(" ")

  system "cd #{tfdir(namespace)}; #{tfinit}"
end

def tfdir(namespace)
  "namespaces/#{CLUSTER}/#{namespace}/resources"
end

def check_prerequisites(namespace, rds_name)
  raise "ERROR First argument 'namespace' not provided" if namespace.nil?
  raise "ERROR Second argument 'rds_name' not provided" if rds_name.nil?
  raise "ERROR namespace resources folder #{tfdir(namespace)} is missing" unless FileTest.directory?(tfdir(namespace))
  check_env_vars
  check_software_installed
  check_aws_profiles
end

def check_env_vars
  REQUIRED_ENV_VARS.each do |var|
    value = ENV.fetch(var, "")
    raise "ERROR Required environment variable #{var} is not set." if value.empty?
  end
end

def check_software_installed
  REQUIRED_EXECUTABLES.each do |exe|
    raise "ERROR Required executable #{exe} not found." unless system("which #{exe}")
  end
end

def check_aws_profiles
  creds = File.read("#{ENV.fetch("HOME")}/.aws/credentials").split("\n")
  REQUIRED_AWS_PROFILES.each do |profile|
    raise "ERROR Required AWS Profile #{profile} not found." \
      unless creds.grep(/\[#{profile}\]/).any?
  end
end

############################################################

namespace, rds_name = ARGV
main(namespace, rds_name)
