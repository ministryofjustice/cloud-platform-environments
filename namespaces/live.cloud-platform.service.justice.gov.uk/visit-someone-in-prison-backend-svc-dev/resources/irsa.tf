# Add the names of the SQS/SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS/SNS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev",
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }

  rds_policies = {
    visit_scheduler_rds              = module.visit_scheduler_rds.irsa_policy_arn,
    prison_visit_booker_registry_rds = module.prison_visit_booker_registry_rds.irsa_policy_arn,
    visit_allocation_rds             = module.visit_allocation_rds.irsa_policy_arn
  }

  all_policies = merge(
    {
      combined_sqs = aws_iam_policy.combined_sqs.arn
    },
    local.sns_policies,
    local.rds_policies
  )
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_iam_policy_document" "combined_sqs" {
  statement {
    sid    = "AllowSqsAccess"
    effect = "Allow"

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListMessageMoveTasks",
      "sqs:ListQueueTags",
      "sqs:CancelMessageMoveTask",
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:StartMessageMoveTask",
    ]

    resources = [
      module.hmpps_prison_visits_event_queue.sqs_arn,
      module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn,
      module.hmpps_prison_visits_notification_alerts_queue.sqs_arn,
      module.hmpps_prison_visits_notification_alerts_dead_letter_queue.sqs_arn,
      module.hmpps_prison_visits_allocation_events_queue.sqs_arn,
      module.hmpps_prison_visits_allocation_events_dead_letter_queue.sqs_arn,
      module.hmpps_prison_visits_allocation_processing_job_queue.sqs_arn,
      module.hmpps_prison_visits_allocation_processing_job_dead_letter_queue.sqs_arn,
      module.hmpps_prison_visits_allocation_prisoner_retry_queue.sqs_arn,
      module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_arn,
      module.hmpps_prison_visits_write_events_queue.sqs_arn,
      module.hmpps_prison_visits_write_events_dead_letter_queue.sqs_arn,
      module.hmpps_prison_visits_create_contact_event_queue.sqs_arn,
      module.hmpps_prison_visits_create_contact_event_dead_letter_queue.sqs_arn,
      module.hmpps_prison_visits_booker_events_queue.sqs_arn,
      module.hmpps_prison_visits_booker_events_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_sqs" {
  name        = "${var.namespace}-${var.application}-combined-sqs"
  description = "Combined SQS access policy for ${var.application}"
  policy      = data.aws_iam_policy_document.combined_sqs.json
}

module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = local.all_policies

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}