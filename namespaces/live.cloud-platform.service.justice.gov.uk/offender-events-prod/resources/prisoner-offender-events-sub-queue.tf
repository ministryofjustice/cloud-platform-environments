module "prisoner_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "prisoner_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_offender_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prisoner_offender_events_queue_policy" {
  queue_url = module.prisoner_offender_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_offender_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_offender_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.offender_events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner_offender_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prisoner_offender_events_queue_dl"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_offender_events_queue" {
  metadata {
    name      = "prisoner-offender-events-queue"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_offender_events_queue.sqs_id
    sqs_queue_arn  = module.prisoner_offender_events_queue.sqs_arn
    sqs_queue_name = module.prisoner_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_offender_events_dead_letter_queue" {
  metadata {
    name      = "prisoner-offender-events-dlq"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_offender_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.prisoner_offender_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.prisoner_offender_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_offender_events_subscription" {
  provider  = aws.london
  topic_arn = module.offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.prisoner_offender_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_MOVEMENT-RECEPTION",
      "OFFENDER_MOVEMENT-DISCHARGE",
      "BOOKING_NUMBER-CHANGED",
      "OFFENDER_CASE_NOTES-INSERTED",
      "OFFENDER_CASE_NOTES-UPDATED",
      "OFFENDER_CASE_NOTES-DELETED",
      "BED_ASSIGNMENT_HISTORY-INSERTED",
      "NON_ASSOCIATION_DETAIL-UPSERTED",
      "RESTRICTION-UPSERTED",
      "PERSON_RESTRICTION-UPSERTED",
      "VISITOR_RESTRICTION-UPSERTED",
      "PRISONER_ACTIVITY-UPDATE",
      "PRISONER_APPOINTMENT-UPDATE"
    ]
  })
}

locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

# IRSA role for prison-offender-events app
module "prison-offender-events-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "prison-offender-events"
  role_policy_arns = merge(
    local.sns_policies,
    {
      prisoner_offender_events_queue = module.prisoner_offender_events_queue.irsa_policy_arn,
      prisoner_offender_events_dlq   = module.prisoner_offender_events_dead_letter_queue.irsa_policy_arn,
      offender_events_topic          = module.offender_events.irsa_policy_arn
  })
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
