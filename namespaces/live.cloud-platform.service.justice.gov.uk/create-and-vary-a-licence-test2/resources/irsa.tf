
# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-cvl_test2_domain_events_queue"       = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-cvl_test2_domain_events_queue_dl"    = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-cvl_prison_test2_events_queue"       = "offender-events-dev",
    "Digital-Prison-Services-dev-cvl_prison_test2_events_queue_dl"    = "offender-events-dev"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  ui_sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
  api_sqs_policies = {
    cvl_domain_events_queue             = module.cvl_domain_events_queue.irsa_policy_arn,
    cvl_domain_events_dead_letter_queue = module.cvl_domain_events_dead_letter_queue.irsa_policy_arn,
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = merge(local.ui_sqs_policies, local.api_sqs_policies, local.sns_policies, { rds_policy = module.create_and_vary_a_licence_api_rds.irsa_policy_arn })
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
