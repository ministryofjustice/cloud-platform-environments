module "prison_to_nhs_update_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "prison_to_nhs_update_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prison_to_nhs_update_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prison_to_nhs_update_queue_policy" {
  queue_url = module.prison_to_nhs_update_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prison_to_nhs_update_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prison_to_nhs_update_queue.sqs_arn}",
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

module "prison_to_nhs_update_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "prison_to_nhs_update_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prison_to_nhs_update_queue" {
  metadata {
    name      = "ptnhs-sqs-instance-output"
    namespace = "prison-to-nhs-update-dev"
  }

  data = {
    access_key_id     = module.prison_to_nhs_update_queue.access_key_id
    secret_access_key = module.prison_to_nhs_update_queue.secret_access_key
    sqs_ptnhs_url     = module.prison_to_nhs_update_queue.sqs_id
    sqs_ptnhs_arn     = module.prison_to_nhs_update_queue.sqs_arn
    sqs_ptnhs_name    = module.prison_to_nhs_update_queue.sqs_name
  }
}

resource "kubernetes_secret" "prison_to_nhs_update_dead_letter_queue" {
  metadata {
    name      = "ptnhs-sqs-dl-instance-output"
    namespace = "prison-to-nhs-update-dev"
  }

  data = {
    access_key_id     = module.prison_to_nhs_update_dead_letter_queue.access_key_id
    secret_access_key = module.prison_to_nhs_update_dead_letter_queue.secret_access_key
    sqs_ptnhs_url     = module.prison_to_nhs_update_dead_letter_queue.sqs_id
    sqs_ptnhs_arn     = module.prison_to_nhs_update_dead_letter_queue.sqs_arn
    sqs_ptnhs_name    = module.prison_to_nhs_update_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prison_to_nhs_update_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prison_to_nhs_update_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"OFFENDER-UPDATED\", \"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"ASSESSMENT_CHANGED\", \"OFFENDER_BOOKING-REASSIGNED\", \"OFFENDER_ALIAS-CHANGED\", \"OFFENDER_BOOKING-CHANGED\", \"OFFENDER_DETAILS-CHANGED\", \"BOOKING_NUMBER-CHANGED\", \"SENTENCE_CALCULATION_DATES-CHANGED\", \"IMPRISONMENT_STATUS-CHANGED\", \"D1_RESULT\"] }"
}

