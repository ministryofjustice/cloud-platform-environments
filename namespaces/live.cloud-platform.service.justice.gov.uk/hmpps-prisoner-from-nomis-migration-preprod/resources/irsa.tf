# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-preprod-hmpps_audit_queue" = "hmpps-audit-preprod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
}

data "aws_iam_policy_document" "combined_local_sqs" {
  version = "2012-10-17"
  statement {
    sid     = "hmppsPrisonerFromNomisMigrationSqs"
    effect  = "Allow"
    actions = ["sqs:*"]
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
      module.migration_nonassociations_queue.sqs_arn,
      module.migration_nonassociations_dead_letter_queue.sqs_arn,
      module.migration_activities_queue.sqs_arn,
      module.migration_activities_dead_letter_queue.sqs_arn,
      module.migration_allocations_queue.sqs_arn,
      module.migration_allocations_dead_letter_queue.sqs_arn
    ]
  }
}

resource "aws_iam_policy" "combined_local_sqs" {
  policy = data.aws_iam_policy_document.combined_local_sqs.json
  tags   = local.default_tags
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-from-nomis-migration"
  role_policy_arns = merge(
    local.sqs_policies,
    { combined_local_sqs = aws_iam_policy.combined_local_sqs.arn },
    {
      prisoner_from_nomis_nonassociations_queue             = module.prisoner_from_nomis_nonassociations_queue.irsa_policy_arn,
      prisoner_from_nomis_nonassociations_dead_letter_queue = module.prisoner_from_nomis_nonassociations_dead_letter_queue.irsa_policy_arn,
      prisoner_from_nomis_sentencing_queue                  = module.prisoner_from_nomis_sentencing_queue.irsa_policy_arn,
      prisoner_from_nomis_sentencing_dead_letter_queue      = module.prisoner_from_nomis_sentencing_dead_letter_queue.irsa_policy_arn,
      prisoner_from_nomis_visits_queue                      = module.prisoner_from_nomis_visits_queue.irsa_policy_arn,
      prisoner_from_nomis_visits_dead_letter_queue          = module.prisoner_from_nomis_visits_dead_letter_queue.irsa_policy_arn,
    }
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
