# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-prisoner_from_nomis_sentencing_dl_queue" = "offender-events-prod"
    "Digital-Prison-Services-prod-prisoner_from_nomis_sentencing_queue"    = "offender-events-prod"
    "Digital-Prison-Services-prod-prisoner_from_nomis_visits_dl_queue"     = "offender-events-prod"
    "Digital-Prison-Services-prod-prisoner_from_nomis_visits_queue"        = "offender-events-prod"
    "Digital-Prison-Services-prod-hmpps_audit_queue"                       = "hmpps-audit-prod"
  }
  sqs_policies = {for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value}
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-from-nomis-migration"
  role_policy_arns     = merge(
    local.sqs_policies,
    {
      migration_appointments_queue = module.migration_appointments_queue.irsa_policy_arn,
      migration_appointments_dlq   = module.migration_appointments_dead_letter_queue.irsa_policy_arn,
      migration_sentencing_queue   = module.migration_sentencing_queue.irsa_policy_arn,
      migration_sentencing_dlq     = module.migration_sentencing_dead_letter_queue.irsa_policy_arn,
      migration_visits_queue       = module.migration_visits_queue.irsa_policy_arn,
      migration_visits_dlq         = module.migration_visits_dead_letter_queue.irsa_policy_arn
    }
  )
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
