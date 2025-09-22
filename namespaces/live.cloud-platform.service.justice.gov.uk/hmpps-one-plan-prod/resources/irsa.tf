locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-hmpps_audit_queue" = "hmpps-audit-prod",
  }
  sqs_policies = {for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value}
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "hmpps-one-plan"
  role_policy_arns       = local.sqs_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
