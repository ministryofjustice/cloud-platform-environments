module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
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

data "kubernetes_secret" "audit_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }
}

module "hmpps-dps-reconciliation-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "hmpps-dps-reconciliation"
  role_policy_arns = merge(
    { audit_sqs = data.kubernetes_secret.audit_secret.data.irsa_policy_arn },
  )
}
