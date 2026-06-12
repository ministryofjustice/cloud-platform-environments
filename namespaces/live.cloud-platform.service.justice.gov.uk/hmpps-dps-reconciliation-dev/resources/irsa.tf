module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-dps-reconciliation"
  role_policy_arns = {
    hmpps_dps_reconciliation_queue             = module.hmpps_dps_reconciliation_queue.irsa_policy_arn
    hmpps_dps_reconciliation_dead_letter_queue = module.hmpps_dps_reconciliation_dead_letter_queue.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
