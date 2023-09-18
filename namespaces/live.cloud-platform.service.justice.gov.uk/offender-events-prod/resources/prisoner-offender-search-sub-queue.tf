module "prisoner_offender_search_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "prisoner_offender_search_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_offender_search_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

resource "aws_sqs_queue_policy" "prisoner_offender_search_queue_policy" {
  queue_url = module.prisoner_offender_search_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_offender_search_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_offender_search_queue.sqs_arn}",
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

module "prisoner_offender_search_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prisoner_offender_search_queue_dl"
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

resource "kubernetes_secret" "prisoner_offender_search_queue" {
  metadata {
    name      = "pos-sqs-instance-output"
    namespace = "prisoner-offender-search-prod"
  }

  data = {
    sqs_pos_url  = module.prisoner_offender_search_queue.sqs_id
    sqs_pos_arn  = module.prisoner_offender_search_queue.sqs_arn
    sqs_pos_name = module.prisoner_offender_search_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_offender_search_dead_letter_queue" {
  metadata {
    name      = "pos-sqs-dl-instance-output"
    namespace = "prisoner-offender-search-prod"
  }

  data = {
    sqs_pos_url  = module.prisoner_offender_search_dead_letter_queue.sqs_id
    sqs_pos_arn  = module.prisoner_offender_search_dead_letter_queue.sqs_arn
    sqs_pos_name = module.prisoner_offender_search_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_offender_search_subscription" {
  provider  = aws.london
  topic_arn = module.offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.prisoner_offender_search_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "OFFENDER-INSERTED",
      "OFFENDER-UPDATED",
      "OFFENDER-DELETED",
      "EXTERNAL_MOVEMENT_RECORD-INSERTED",
      "EXTERNAL_MOVEMENT-CHANGED",
      "SENTENCING-CHANGED",
      "ASSESSMENT-CHANGED",
      "ASSESSMENT-UPDATED",
      "OFFENDER_BOOKING-REASSIGNED",
      "OFFENDER_BOOKING-CHANGED",
      "OFFENDER_DETAILS-CHANGED",
      "BOOKING_NUMBER-CHANGED",
      "SENTENCE_DATES-CHANGED",
      "IMPRISONMENT_STATUS-CHANGED",
      "BED_ASSIGNMENT_HISTORY-INSERTED",
      "CONFIRMED_RELEASE_DATE-CHANGED",
      "ALERT-INSERTED",
      "ALERT-UPDATED",
      "OFFENDER_ALIAS-CHANGED",
      "OFFENDER_PROFILE_DETAILS-INSERTED",
      "OFFENDER_PROFILE_DETAILS-UPDATED",
      "OFFENDER_PHYSICAL_DETAILS-CHANGED",
      "OFFENDER_IDENTIFIER-UPDATED",
      "COURT_SENTENCE-CHANGED"
    ]
  })
}
