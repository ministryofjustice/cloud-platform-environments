module "case_note_poll_pusher_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "case_note_poll_pusher_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.case_note_poll_pusher_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "case_note_poll_pusher_queue_policy" {
  queue_url = module.case_note_poll_pusher_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.case_note_poll_pusher_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.case_note_poll_pusher_queue.sqs_arn}",
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

module "case_note_poll_pusher_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "case_note_poll_pusher_queue_dl"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sns_topic_subscription" "case_note_poll_pusher_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.case_note_poll_pusher_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"PRISON-RELEASE\", \"TRANSFER-FROMTOL\", \"GEN-OSE\", \"ALERT-ACTIVE\", \"ALERT-INACTIVE\", {\"prefix\": \"OMIC\"}, {\"prefix\": \"OMIC_OPD\"}, {\"prefix\": \"KA\"} ] }"
}

