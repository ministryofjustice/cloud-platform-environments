locals {
  sqs_queues_ap = {
    "Digital-Prison-Services-preprod-hmpps_audit_queue" = "hmpps-audit-preprod",
  }
  sqs_queues_cas2 = {
    "Digital-Prison-Services-preprod-hmpps_audit_queue" = "hmpps-audit-preprod",
  }
  sqs_queues_ta = {
    "Digital-Prison-Services-preprod-hmpps_audit_queue" = "hmpps-audit-preprod",
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }
  sns_policies      = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
  sqs_policies_ap   = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_ap : item.name => item.value }
  sqs_policies_cas2 = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_cas2 : item.name => item.value }
  sqs_policies_ta   = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_cas2 : item.name => item.value }
}

module "irsa" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name       = var.eks_cluster_name
  service_account_name   = "hmpps-community-accommodation-api-service-account"
  namespace              = var.namespace
  role_policy_arns       = local.sns_policies
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_ap" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name       = var.eks_cluster_name
  service_account_name   = "hmpps-approved-premises-service-account"
  namespace              = var.namespace
  role_policy_arns       = local.sqs_policies_ap
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_cas2" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name       = var.eks_cluster_name
  service_account_name   = "hmpps-community-accommodation-tier-2-service-account"
  namespace              = var.namespace
  role_policy_arns       = local.sqs_policies_cas2
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_ta" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name       = var.eks_cluster_name
  service_account_name   = "hmpps-temporary-accommodation-service-account"
  namespace              = var.namespace
  role_policy_arns       = local.sqs_policies_ta
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sqs_ap" {
  for_each = local.sqs_queues_ap
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sqs_cas2" {
  for_each = local.sqs_queues_cas2
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sqs_ta" {
  for_each = local.sqs_queues_ta
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
