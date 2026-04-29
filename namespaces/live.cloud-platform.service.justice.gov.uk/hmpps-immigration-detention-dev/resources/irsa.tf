locals {
  ui_sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_ui_sqs : item.name => item.value}
  ui_sqs_queues = {
      "Digital-Prison-Services-${var.environment}-hmpps_audit_queue" = "hmpps-audit-${var.environment}"
  }
}

module "irsa-ui" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-immigration-detention-ui"
  role_policy_arns     = local.ui_sqs_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_ui_sqs" {
  for_each = local.ui_sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}