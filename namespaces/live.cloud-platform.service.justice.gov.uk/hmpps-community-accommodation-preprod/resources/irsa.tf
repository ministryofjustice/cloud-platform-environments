locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }
  sns_policies = {for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value}
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "hmpps-community-accommodation-api-service-account"
  namespace = var.namespace
  role_policy_arns = local.sns_policies
  business_unit = var.business_unit
  application = var.application
  is_production = var.is_production
  team_name = var.team_name
  environment_name = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
