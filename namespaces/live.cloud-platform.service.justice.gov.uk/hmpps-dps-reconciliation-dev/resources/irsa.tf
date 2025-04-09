module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name
  service_account_name = "hmpps-dps-reconciliation"
  role_policy_arns     = merge(
    {
      rds = module.hmpps_dps_reconciliation_rds.irsa_policy_arn
    },
    {
      sqs = module.hmpps_dps_reconciliation_queue.irsa_policy_arn
    },
    {
      sqs_dlq = module.hmpps_dps_reconciliation_dead_letter_queue.irsa_policy_arn
    },
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
