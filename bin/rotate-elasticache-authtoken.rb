#!/usr/bin/env ruby

# Script to taint and recreate the auth_token for an elasticache cluster, and
# then slowly delete all pods in the corresponding namespace to allow new pods
# to be created, which will pick up the new auth_token from the kubernetes
# secret.
#
# NB: THIS WILL DESTROY AND RECREATE THE ELASTICACHE CLUSTER
#
# Currently, the AWS API does not have any way to rotate the auth_token of an
# elasticache cluster without destroying and recreating it. This seems to take
# around 15 minutes - half to tear down the old cluster, and half to build a
# new one. Any data in the original elasticache cluster is presumed to be lost.

REQUIRED_ENV_VARS = %w[AWS_PROFILE TF_VAR_cluster_name TF_VAR_cluster_state_bucket TF_VAR_cluster_state_key]
REQUIRED_EXECUTABLES = %w[terraform kubectl cut grep which]
REQUIRED_AWS_PROFILES = %w[moj-cp]

CLUSTER = "live-1.cloud-platform.service.justice.gov.uk"

TF_STATE_REGION = "eu-west-1"
TF_STATE_BUCKET = "cloud-platform-terraform-state"
TF_STATE_LOCK_TABLE = "cloud-platform-environments-terraform-lock"

def main(namespace, cluster_name)
  check_prerequisites(namespace, cluster_name)
  replace_credentials(namespace, cluster_name)
  replace_pods(namespace)
end

def replace_credentials(namespace, cluster_name)
  tfinit(namespace)
  taint_auth_token(namespace, cluster_name)
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

# e.g. for cluster module = service-token-elasticache, we taint "module.service-token-elasticache.auth_token"
def taint_auth_token(namespace, cluster_name)
  target = "module.#{cluster_name}.auth_token"
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

def check_prerequisites(namespace, cluster_name)
  raise "ERROR First argument 'namespace' not provided" if namespace.nil?
  raise "ERROR Second argument 'cluster_name' not provided" if cluster_name.nil?
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

namespace, cluster_name = ARGV
main(namespace, cluster_name)
