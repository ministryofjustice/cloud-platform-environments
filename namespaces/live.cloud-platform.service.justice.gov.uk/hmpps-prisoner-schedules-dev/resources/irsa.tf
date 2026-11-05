# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue" = "hmpps-audit-dev"
    "hmpps-move-and-improve-dev-producer_event_sqs_queue" = "hmpps-move-and-improve-dev"
    "hmpps-move-and-improve-dev-producer_event_sqs_dlq"   = "hmpps-move-and-improve-dev"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name

  service_account_name = "hmpps-prisoner-schedules-api"
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  role_policy_arns = merge(
    {
    sqs = module.producer_event_sqs_queue.irsa_policy_arn
    },
    {
    sqs_dlq = module.producer_event_sqs_dlq.irsa_policy_arn
    },
    local.sqs_policies,
  )
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
