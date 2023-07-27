# Add the names of the SQS/SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS/SNS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "book-a-prison-visit-staging-hmpps_prison_visits_event_queue" = var.namespace,
    "book-a-prison-visit-staging-hmpps_prison_visits_event_dlq" = var.namespace,
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev",
  }

  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = merge(local.sqs_policies,local.sns_policies)

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name
}
