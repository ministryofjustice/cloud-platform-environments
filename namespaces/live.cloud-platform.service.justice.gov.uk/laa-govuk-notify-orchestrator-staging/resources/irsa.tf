module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  
  role_policy_arns = {
        laa_govuk_notify_orchestrator_staging_sqs       = module.laa_govuk_notify_orchestrator_staging_sqs.irsa_policy_arn
        laa_govuk_notify_orchestrator_staging_dlq       = module.laa_govuk_notify_orchestrator_staging_dlq.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}