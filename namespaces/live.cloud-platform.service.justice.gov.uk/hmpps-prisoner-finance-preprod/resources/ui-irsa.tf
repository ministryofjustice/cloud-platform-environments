locals {
  sqs_queues = {
    "Digital-Prison-Services-preprod-hmpps_audit_queue" = "hmpps-audit-preprod",
  }
  sqs_policies        = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  pf_ui_irsa_policies = merge(local.sqs_policies)
}

module "hmpps_prisoner_finance_ui_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.service_account_name_ui
  role_policy_arns     = local.pf_ui_irsa_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}