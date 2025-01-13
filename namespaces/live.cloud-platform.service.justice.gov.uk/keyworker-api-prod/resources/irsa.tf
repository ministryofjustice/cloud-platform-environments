# Add the names of the SQS & SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-keyworker_api_queue"                       = "offender-events-prod",
    "Digital-Prison-Services-prod-keyworker_api_queue_dl"                    = "offender-events-prod",
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  role_policy_arns = merge(
    {
      rds = module.dps_rds.irsa_policy_arn
    },
    {
      sqs = module.keyworker_domain_events_queue.irsa_policy_arn
    },
    {
      sqs_dlq = module.keyworker_domain_events_dlq.irsa_policy_arn
    },
    local.sqs_policies
  )
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
