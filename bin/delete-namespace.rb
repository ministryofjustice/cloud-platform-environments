#!/usr/bin/env ruby

# This script will delete all AWS resources belonging to a namespace,
# and will then delete the namespace itself from the live-1 cluster.
#
# The script requires the following environment variables:
#
#   # Env vars to allow terraform to work on the S3 state files
#   export AWS_ACCESS_KEY_ID=[redacted]
#   export AWS_SECRET_ACCESS_KEY=[redacted]
#   export PIPELINE_STATE_BUCKET=cloud-platform-terraform-state
#   export PIPELINE_STATE_KEY_PREFIX="cloud-platform-environments/"
#   export PIPELINE_TERRAFORM_STATE_LOCK_TABLE=cloud-platform-environments-terraform-lock
#   export PIPELINE_STATE_REGION="eu-west-1"
#   export TF_VAR_cluster_name=live-1.cloud-platform.service.justice.gov.uk
#   export TF_VAR_cluster_state_bucket=cloud-platform-terraform-state
#   export TF_VAR_cluster_state_key=cloud-platform/live-1/terraform.tfstate
#
#   # Env vars to enable kubectl to operate on the cluster by grabbing the kubeconfig
#   # file from S3
#   export KUBECONFIG_AWS_ACCESS_KEY_ID=[redacted]
#   export KUBECONFIG_AWS_SECRET_ACCESS_KEY=[redacted]
#   export KUBECONFIG_AWS_REGION=eu-west-2
#   export KUBECONFIG_S3_BUCKET=cloud-platform-concourse-kubeconfig
#   export KUBECONFIG_S3_KEY=kubeconfig
#   export KUBE_CONFIG=/tmp/kubeconfig
#   export KUBE_CTX=live-1.cloud-platform.service.justice.gov.uk

require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")

namespace = ARGV.shift

CpEnv::NamespaceDeleter.new(namespace: namespace).delete
