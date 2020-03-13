#!/usr/bin/env ruby

# This script takes a namespace name, and:
#
#  * updates all references to our RDS module to use the latest version
#  * runs terraform apply
#  * gracefully deletes all pods in the namespace, in turn
#
# This was originally done because a version change in the RDS module changed
# the password from `random_string` to `random_password`. This recreates the
# kubernetes secret which contains the password, so all pods need to be
# relaunched so that they pick up the new database credential. Generally this
# should not cause any application downtime, because database connections which
# were created with the 'old' password should continue to work, even after the
# database password has been updated.

REQUIRED_ENV_VARS = %w[AWS_PROFILE TF_VAR_cluster_name TF_VAR_cluster_state_bucket TF_VAR_cluster_state_key]
REQUIRED_EXECUTABLES = %w[terraform kubectl cut grep sed which hub]
REQUIRED_AWS_PROFILES = %w[moj-cp]

CLUSTER = "live-1.cloud-platform.service.justice.gov.uk"

TF_STATE_REGION = "eu-west-1"
TF_STATE_BUCKET = "cloud-platform-terraform-state"
TF_STATE_LOCK_TABLE = "cloud-platform-environments-terraform-lock"

# NB: This only works if the version number is exactly 3 characters, e.g. "5.1"
# Also, watch out for the double backslashes - you need those, when running
# within ruby, but not if you execute the sed directly in your shell.
RDS_MODULE_REGEX = "github.com\\/ministryofjustice\\/cloud-platform-terraform-rds-instance.ref=..."
LATEST_RDS_MODULE = "github.com\\/ministryofjustice\\/cloud-platform-terraform-rds-instance?ref=5.3"

def main(namespace)
  check_prerequisites(namespace)
  update_rds_module(namespace)
  if terraform_apply(namespace)
    replace_pods(namespace)
    raise_pr(namespace)
  end
end

def update_rds_module(namespace)
  cmd = %(cd #{tfdir(namespace)}; sed -i '' 's/#{RDS_MODULE_REGEX}/#{LATEST_RDS_MODULE}/' *.tf)
  puts cmd
  system cmd
end

def terraform_apply(namespace)
  dir = tfdir(namespace)
  updated_files = `git status --porcelain=1 #{dir}`.split("\n")

  pp updated_files

  # We don't want to run terraform apply and replace all the pods if nothing
  # changed (i.e. this namespace doesn't use the RDS module, or it was already
  # using the latest version.
  return false if updated_files.empty?

  tfinit(namespace)
  system "cd #{dir}; terraform apply -auto-approve"
  true
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

# Create a PR to put the RDS module change into the environments repo.
def raise_pr(namespace)
  branch = "update-rds-module-#{namespace}"
  message = "Update RDS module for #{namespace}"
  system "git checkout -b #{branch}"
  system "git add #{tfdir(namespace)}"
  system %(git commit -m "#{message}")
  system %(git push origin #{branch})
  system %(hub pull-request -m "#{message}")
end

def tfinit(namespace)
  cmd = [
    %(terraform init),
    %(-backend-config="bucket=#{TF_STATE_BUCKET}"),
    %(-backend-config="key=cloud-platform-environments/#{CLUSTER}/#{namespace}/terraform.tfstate"),
    %(-backend-config="region=#{TF_STATE_REGION}"),
    %(-backend-config="dynamodb_table=#{TF_STATE_LOCK_TABLE}")
  ].join(" ")

  puts cmd

  system "cd #{tfdir(namespace)}; #{cmd}"
end

def get_pods(namespace)
  cmd = %(kubectl -n #{namespace} get pods | grep Running | cut -f 1 -d' ')
  `#{cmd}`.split("\n")
end

def check_prerequisites(namespace)
  dir = tfdir(namespace)
  raise "ERROR namespace resources folder #{dir} is missing" unless FileTest.directory?(dir)
  check_env_vars
  check_cluster_info
  check_software_installed
  check_aws_profiles
end

def check_env_vars
  REQUIRED_ENV_VARS.each do |var|
    value = ENV.fetch(var, "")
    raise "ERROR Required environment variable #{var} is not set." if value.empty?
  end
end

def check_cluster_info
  unless system "kubectl cluster-info | grep #{CLUSTER}"
    raise "ERROR: kubectl cluster-info does not match #{CLUSTER}"
  end
end

def check_software_installed
  REQUIRED_EXECUTABLES.each do |exe|
    # TODO: find a reliable way to test for the presence of an executable without
    # echoing so much output to stdout
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

def tfdir(namespace)
  "namespaces/#{CLUSTER}/#{namespace}/resources"
end

############################################################

namespace = ARGV.shift
raise "ERROR Required argument 'namespace' not provided" if namespace.nil?
main(namespace)
