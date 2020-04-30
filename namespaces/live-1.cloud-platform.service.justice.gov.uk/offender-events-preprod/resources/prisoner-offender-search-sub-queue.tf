module "prisoner_offender_search_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "prisoner_offender_search_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_offender_search_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF


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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "prisoner_offender_search_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}


resource "aws_sns_topic_subscription" "prisoner_offender_search_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prisoner_offender_search_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"OFFENDER-UPDATED\", \"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"ASSESSMENT-CHANGED\", \"OFFENDER_BOOKING-REASSIGNED\", \"OFFENDER_BOOKING-CHANGED\", \"OFFENDER_DETAILS-CHANGED\", \"BOOKING_NUMBER-CHANGED\", \"SENTENCE_DATES-CHANGED\", \"IMPRISONMENT_STATUS-CHANGED\", \"BED_ASSIGNMENT_HISTORY-INSERTED\"] }"
}

