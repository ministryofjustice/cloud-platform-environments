locals {
  sns_local = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-interventions"
  namespace            = var.namespace
  role_policy_arns = merge(local.sns_policies, {
    s3 = module.interventions_s3_bucket.irsa_policy_arn
    elasticache = module.hmpps_interventions_elasticache_redis.irsa_policy_arn
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sns_local
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
