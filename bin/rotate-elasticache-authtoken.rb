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

require "open3"

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
  execute "cd #{tfdir(namespace)}; terraform apply -auto-approve"
end

# For elasticache, the app will be broken until the pods are replaced, so we should do that as
# quickly as possible. The 5 second sleep may not be useful.
def replace_pods(namespace, delay = 5)
  get_pods(namespace).each do |pod|
    execute "kubectl -n #{namespace} delete pod #{pod}"
    sleep delay # This could be optimised, because there's no need to sleep after deleting the last pod
  end
end

def get_pods(namespace)
  cmd = %(kubectl -n #{namespace} get pods | grep Running | cut -f 1 -d' ')
  `#{cmd}`.split("\n")
end

# e.g. for cluster module = service-token-elasticache, we taint "module.service-token-elasticache.random_id.auth_token"
def taint_auth_token(namespace, cluster_name)
  target = "module.#{cluster_name}.random_id.auth_token"
  execute "cd #{tfdir(namespace)}; terraform taint #{target}"
end

def tfinit(namespace)
  tfinit = [
    %(terraform init),
    %(-backend-config="bucket=#{TF_STATE_BUCKET}"),
    %(-backend-config="key=cloud-platform-environments/#{CLUSTER}/#{namespace}/terraform.tfstate"),
    %(-backend-config="region=#{TF_STATE_REGION}"),
    %(-backend-config="dynamodb_table=#{TF_STATE_LOCK_TABLE}")
  ].join(" ")

  execute "cd #{tfdir(namespace)}; #{tfinit}"
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

def execute(cmd)
  puts "executing: #{cmd}"

  stdout, stderr, status = Open3.capture3(cmd)

  unless status.success?
    puts "Command: #{cmd} failed."
    puts stderr
    raise
  end

  puts stdout

  [stdout, stderr, status]
end

############################################################

namespace, cluster_name = ARGV
main(namespace, cluster_name)
