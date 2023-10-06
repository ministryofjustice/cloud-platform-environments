
# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-cvl_test2_domain_events_queue"       = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-cvl_test2_domain_events_queue_dl"    = "hmpps-domain-events-dev",
    "Digital-Prison-Services-dev-cvl_probation_test2_events_queue"    = "offender-events-dev",
    "Digital-Prison-Services-dev-cvl_probation_test2_events_queue_dl" = "offender-events-dev",
    "Digital-Prison-Services-dev-cvl_prison_test2_events_queue"       = "offender-events-dev",
    "Digital-Prison-Services-dev-cvl_prison_test2_events_queue_dl"    = "offender-events-dev"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = local.sqs_policies
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
