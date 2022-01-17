module "prisoner_offender_search_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "prisoner_offender_search_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "prisoner_offender_search_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_offender_search_queue" {
  metadata {
    name      = "pos-sqs-instance-output"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # namespace = "prisoner-offender-search-preprod"
  }

  data = {
    access_key_id     = module.prisoner_offender_search_queue.access_key_id
    secret_access_key = module.prisoner_offender_search_queue.secret_access_key
    sqs_pos_url       = module.prisoner_offender_search_queue.sqs_id
    sqs_pos_arn       = module.prisoner_offender_search_queue.sqs_arn
    sqs_pos_name      = module.prisoner_offender_search_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_offender_search_dead_letter_queue" {
  metadata {
    name      = "pos-sqs-dl-instance-output"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # namespace = "prisoner-offender-search-preprod"
  }

  data = {
    access_key_id     = module.prisoner_offender_search_dead_letter_queue.access_key_id
    secret_access_key = module.prisoner_offender_search_dead_letter_queue.secret_access_key
    sqs_pos_url       = module.prisoner_offender_search_dead_letter_queue.sqs_id
    sqs_pos_arn       = module.prisoner_offender_search_dead_letter_queue.sqs_arn
    sqs_pos_name      = module.prisoner_offender_search_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_offender_search_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prisoner_offender_search_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"OFFENDER-INSERTED\", \"OFFENDER-UPDATED\", \"OFFENDER-DELETED\", \"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"ASSESSMENT-CHANGED\", \"OFFENDER_BOOKING-REASSIGNED\", \"OFFENDER_BOOKING-CHANGED\", \"OFFENDER_DETAILS-CHANGED\", \"BOOKING_NUMBER-CHANGED\", \"SENTENCE_DATES-CHANGED\", \"IMPRISONMENT_STATUS-CHANGED\", \"BED_ASSIGNMENT_HISTORY-INSERTED\", \"CONFIRMED_RELEASE_DATE-CHANGED\", \"ALERT-INSERTED\", \"ALERT-UPDATED\", \"OFFENDER_ALIAS-CHANGED\", \"OFFENDER_PROFILE_DETAILS-INSERTED\", \"OFFENDER_PROFILE_DETAILS-UPDATED\"] }"
}
