
module "probation-search-ui-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "probation-search-ui"
  role_policy_arns = merge(
    { elasticache = module.elasticache.irsa_policy_arn },
    { audit_sqs = data.kubernetes_secret.audit_secret.data.irsa_policy_arn },
  )
}

module "probation-search-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "probation-search"
  role_policy_arns = merge(
    { elasticache = module.elasticache.irsa_policy_arn },
    { audit_sqs = data.kubernetes_secret.audit_secret.data.irsa_policy_arn },
  )
}
