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

data "aws_iam_policy_document" "combined_local_sqs" {
  version = "2012-10-17"
  statement {
    sid       = "hmppsPrisonerToNomisUpdateSqs"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = [
      module.hmpps_prisoner_to_nomis_adjudication_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_adjudication_dead_letter_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_nonassociation_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_nonassociation_dead_letter_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_activity_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_activity_dead_letter_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_appointment_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_appointment_dead_letter_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_incentive_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_incentive_dead_letter_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_sentencing_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_sentencing_dead_letter_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_visit_queue.sqs_arn,
      module.hmpps_prisoner_to_nomis_visit_queue.sqs_arn
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
  service_account_name = "hmpps-prisoner-to-nomis-update"
  role_policy_arns     = merge(
    local.sqs_policies,
    { combined_local_sqs = aws_iam_policy.combined_local_sqs.arn }
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

locals {
  default_tags = {
    namespace              = var.namespace
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}
