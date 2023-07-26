resource "aws_sns_topic_subscription" "hmpps_prisoner_search_offender_subscription" {
  provider      = aws.london
  topic_arn     = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol      = "sqs"
  endpoint      = module.hmpps_prisoner_search_offender_queue.sqs_arn
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

module "hmpps_prisoner_search_offender_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_prisoner_search_offender_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_search_offender_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_prisoner_search_offender_queue_policy" {
  queue_url = module.hmpps_prisoner_search_offender_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prisoner_search_offender_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prisoner_search_offender_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.offender-events-topic-arn.value}"
                          }
                        }
        }
      ]
  }

EOF

}

module "hmpps_prisoner_search_offender_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_prisoner_search_offender_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prisoner_search_offender_queue" {
  metadata {
    name      = "sqs-offender-event-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_search_offender_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_search_offender_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_search_offender_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_search_offender_dlq" {
  metadata {
    name      = "sqs-offender-event-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_search_offender_dlq.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_search_offender_dlq.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_search_offender_dlq.sqs_name
  }
}

data "aws_ssm_parameter" "offender-events-topic-arn" {
  name = "/offender-events-dev/topic-arn"
}
