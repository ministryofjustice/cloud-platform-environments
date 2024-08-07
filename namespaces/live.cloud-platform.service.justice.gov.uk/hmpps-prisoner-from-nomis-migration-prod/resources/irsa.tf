# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-hmpps_audit_queue" = "hmpps-audit-prod"
  }
  sqs_policies = {for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value}
}

data "aws_iam_policy_document" "combined_local_sqs_migration" {
  version = "2012-10-17"
  statement {
    sid       = "hmppsPrisonerFromNomisMigrationSqs"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = [
      module.migration_appointments_queue.sqs_arn,
      module.migration_appointments_dead_letter_queue.sqs_arn,
      module.migration_sentencing_queue.sqs_arn,
      module.migration_sentencing_dead_letter_queue.sqs_arn,
      module.migration_visits_queue.sqs_arn,
      module.migration_visits_dead_letter_queue.sqs_arn,
      module.migration_adjudications_queue.sqs_arn,
      module.migration_adjudications_dead_letter_queue.sqs_arn,
      module.migration_incidents_queue.sqs_arn,
      module.migration_incidents_dead_letter_queue.sqs_arn,
      module.migration_locations_queue.sqs_arn,
      module.migration_locations_dead_letter_queue.sqs_arn,
      module.migration_activities_queue.sqs_arn,
      module.migration_activities_dead_letter_queue.sqs_arn,
      module.migration_allocations_queue.sqs_arn,
      module.migration_allocations_dead_letter_queue.sqs_arn,
      module.migration_alerts_queue.sqs_arn,
      module.migration_alerts_dead_letter_queue.sqs_arn,
      module.migration_casenotes_queue.sqs_arn,
      module.migration_casenotes_dead_letter_queue.sqs_arn,
      module.migration_csip_queue.sqs_arn,
      module.migration_csip_dead_letter_queue.sqs_arn,
      module.migration_prisonperson_queue.sqs_arn,
      module.migration_prisonperson_dead_letter_queue.sqs_arn,
      module.migration_courtsentencing_queue.sqs_arn,
      module.migration_courtsentencing_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_local_sqs_migration" {
  policy = data.aws_iam_policy_document.combined_local_sqs_migration.json
  tags   = local.default_tags
}

data "aws_iam_policy_document" "combined_local_sqs_events" {
  version = "2012-10-17"
  statement {
    sid       = "hmppsPrisonerFromNomisEventSqs"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = [
      module.prisoner_from_nomis_incidents_queue.sqs_arn,
      module.prisoner_from_nomis_incidents_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_csip_queue.sqs_arn,
      module.prisoner_from_nomis_csip_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_locations_queue.sqs_arn,
      module.prisoner_from_nomis_locations_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_sentencing_queue.sqs_arn,
      module.prisoner_from_nomis_sentencing_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_visits_queue.sqs_arn,
      module.prisoner_from_nomis_visits_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_alerts_queue.sqs_arn,
      module.prisoner_from_nomis_alerts_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_casenotes_queue.sqs_arn,
      module.prisoner_from_nomis_casenotes_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_courtsentencing_queue.sqs_arn,
      module.prisoner_from_nomis_courtsentencing_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_prisonperson_queue.sqs_arn,
      module.prisoner_from_nomis_prisonperson_dead_letter_queue.sqs_arn,
      module.prisoner_from_nomis_courtsentencing_queue.sqs_arn,
      module.prisoner_from_nomis_courtsentencing_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_local_sqs_events" {
  policy = data.aws_iam_policy_document.combined_local_sqs_events.json
  tags   = local.default_tags
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-from-nomis-migration"
  role_policy_arns     = merge(
    local.sqs_policies,
    { combined_local_sqs_migration = aws_iam_policy.combined_local_sqs_migration.arn },
    { combined_local_sqs_events = aws_iam_policy.combined_local_sqs_events.arn },
  )
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
