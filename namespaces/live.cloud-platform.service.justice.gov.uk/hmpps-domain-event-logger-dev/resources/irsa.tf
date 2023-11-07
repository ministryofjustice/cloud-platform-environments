# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  irsa_policies = {
    hmpps_domain_event_logger_queue             = module.hmpps_domain_event_logger_queue.irsa_policy_arn
    hmpps_domain_event_logger_dead_letter_queue = module.hmpps_domain_event_logger_dead_letter_queue.irsa_policy_arn
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "hmpps-domain-event-logger"
  role_policy_arns       = local.irsa_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
