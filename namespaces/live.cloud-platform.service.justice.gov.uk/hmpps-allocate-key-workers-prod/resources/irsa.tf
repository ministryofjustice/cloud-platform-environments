data "kubernetes_secret" "audit_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }
}

module "hmpps-allocate-key-workers-ui-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "hmpps-allocate-key-workers-ui"
  role_policy_arns = merge(
    { elasticache = module.elasticache_redis.irsa_policy_arn },
    { audit_sqs = data.kubernetes_secret.audit_secret.data.irsa_policy_arn },
  )
}