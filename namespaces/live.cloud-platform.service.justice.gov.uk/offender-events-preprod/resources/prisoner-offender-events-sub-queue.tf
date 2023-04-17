module "prisoner_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "prisoner_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_offender_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "prisoner_offender_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_offender_events_queue" {
  metadata {
    name      = "prisoner-offender-events-queue"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prisoner_offender_events_queue.access_key_id
    secret_access_key = module.prisoner_offender_events_queue.secret_access_key
    sqs_queue_url     = module.prisoner_offender_events_queue.sqs_id
    sqs_queue_arn     = module.prisoner_offender_events_queue.sqs_arn
    sqs_queue_name    = module.prisoner_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_offender_events_dead_letter_queue" {
  metadata {
    name      = "prisoner-offender-events-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prisoner_offender_events_dead_letter_queue.access_key_id
    secret_access_key = module.prisoner_offender_events_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.prisoner_offender_events_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.prisoner_offender_events_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.prisoner_offender_events_dead_letter_queue.sqs_name
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
      "VISITOR_RESTRICTION-UPSERTED"
    ]
  })
}

