# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_activity_dlq"     = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_activity_queue"   = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-prisoner_to_nomis_appointment_dlq"        = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-prisoner_to_nomis_appointment_queue"      = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_incentive_dlq"    = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_incentive_queue"  = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_sentencing_dlq"   = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_sentencing_queue" = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_visit_dlq"        = "hmpps-domain-events-dev"
    "Digital-Prison-Services-dev-hmpps_prisoner_to_nomis_visit_queue"      = "hmpps-domain-events-dev"
  }
  sqs_policies = {for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value}
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "hmpps-prisoner-to-nomis-update"
  role_policy_arns       = local.sqs_policies
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
