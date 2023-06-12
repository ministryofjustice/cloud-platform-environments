# Add the names of the SQS & SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-rp_queue_for_domain_events" = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-rp_queue_for_domain_events_dl" = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-restricted_patients_queue" = "offender-events-dev",
    "Digital-Prison-Services-dev-restricted_patients_queue_dl" = "offender-events-dev"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sqs_policies = { for item in data.irsa_policy_arns_sqs.irsa_policy_arns : item.name => item.value }
  sns_policies = { for item in data.irsa_policy_arns_sns.irsa_policy_arns : item.name => item.value }
  irsa_policies = merge(local.sqs_policies, local.sns_policies)
}

module "hmpps-restricted-patients" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns = local.irsa_policies
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

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
