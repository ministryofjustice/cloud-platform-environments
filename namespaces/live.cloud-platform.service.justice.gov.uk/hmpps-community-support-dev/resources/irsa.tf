# This information is used to collect the IAM policies which are used by the IRSA module.

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "hmpps-community-support"

  role_policy_arns = {
    elasticache = module.elasticache_redis.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}
