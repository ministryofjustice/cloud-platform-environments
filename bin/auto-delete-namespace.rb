#!/usr/bin/env ruby

# concourse pipleline "destroy-deleted-namespaces" run this script to detect deleted namespaces
# and delete all AWS resources belonging to the deleted namespace,
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
#   export KUBECONFIG_S3_BUCKET=cloud-platform-concourse-kubeconfig
#   export KUBECONFIG_S3_KEY=kubeconfig
#   export KUBE_CONFIG=/tmp/kubeconfig
#   export KUBE_CTX=live-1.cloud-platform.service.justice.gov.uk

require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")

def main(cluster)
  log("green", "Checking if any namespaces deleted in the cluster #{cluster}")

  namespaces = deleted_namespaces(cluster)

  if namespaces.any?
    msg = <<~EOF
      Deleting following namespaces which have been removed from the environments repository:
  
        - #{namespaces.join("\n  - ")}
  
    EOF

    puts msg
    deleted_namespaces(cluster).each do |namespace|
      CpEnv::NamespaceDeleter.new(namespace: namespace).delete
    end

  else
    puts "No namespaces to delete"
  end

  log("green", "Done.")
end

main ENV.fetch("PIPELINE_CLUSTER")
