# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
  static_sqs_policies = {
    hmpps_unused_deductions_queue                   = module.hmpps_unused_deductions_queue.irsa_policy_arn,
    hmpps_unused_deductions_dead_letter_queue       = module.hmpps_unused_deductions_dead_letter_queue.irsa_policy_arn,
    hmpps_adjustments_prisoner_queue                = module.hmpps_adjustments_prisoner_queue.irsa_policy_arn,
    hmpps_adjustments_prisoner_dead_letter_queue    = module.hmpps_adjustments_prisoner_dead_letter_queue.irsa_policy_arn,
  }
  dynamic_sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sqs_policies = merge(local.static_sqs_policies, local.dynamic_sqs_policies)
  sqs_queues = {
    "Digital-Prison-Services-${var.environment_name}-hmpps_audit_queue" = "hmpps-audit-${var.environment_name}"
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = merge(local.sqs_policies, local.sns_policies)
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}