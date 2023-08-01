locals {
  sqs_queues = {
     "hmpps_tier_offender_events_queue" = "offender-events-dev"
     "hmpps_tier_offender_events_dead_letter_queue" = "offender-events-dev"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }

  hmpps_sqs_policies =   { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  domain_sqs_policies = {
    sqs = module.hmpps_tier_domain_events_queue.irsa_policy_arn,
    dlq = module.hmpps_tier_domain_events_dead_letter_queue.irsa_policy_arn
    }
  sqs_policies = merge(
    hmpps_sqs_policies,
    domain_sqs_policies
  )


  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = var.application
  namespace             = var.namespace
  role_policy_arns = merge(
    sns = local.sns_policies,
    sqs = local.sqs_policies
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}