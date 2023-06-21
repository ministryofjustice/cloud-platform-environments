# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue" = "hmpps-audit-dev",
  }
}

module "app-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

   eks_cluster_name     = var.eks_cluster_name
   namespace            = var.namespace
   service_account_name = "${var.team_name}-${var.environment}"
   role_policy_arns = {
    hmpps_audit_dlq = module.hmpps_audit_dlq.irsa_policy_arn,
    hmpps_audit_queue = module.hmpps_audit_queue.irsa_policy_arn
   }

    # Tags
     business_unit          = var.business_unit
     application            = var.application
     is_production          = var.is_production
     team_name              = var.team_name
     environment_name       = var.environment
     infrastructure_support = var.infrastructure_support
}
