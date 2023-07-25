locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sns_policies = {for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value}
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "hmpps-community-accommodation-api-service-account"
  namespace = var.namespace
  role_policy_arns = {
    local.sns_policies,
  }
  business_unit = var.business_unit
  application = var.application
  is_production = var.is_production
  team_name = var.team_name
  environment_name = var.environment
  infrastructure_support = var.infrastructure_support
}
