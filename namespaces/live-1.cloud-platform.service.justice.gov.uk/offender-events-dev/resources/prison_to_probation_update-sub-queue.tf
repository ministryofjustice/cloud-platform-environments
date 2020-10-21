module "prison_to_probation_update_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "prison_to_probation_update_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prison_to_probation_update_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prison_to_probation_update_queue_policy" {
  queue_url = module.prison_to_probation_update_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prison_to_probation_update_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prison_to_probation_update_queue.sqs_arn}",
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

module "prison_to_probation_update_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "prison_to_probation_update_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prison_to_probation_update_queue" {
  metadata {
    name      = "ptpu-sqs-instance-output"
    namespace = "prison-to-probation-update-dev"
  }

  data = {
    access_key_id     = module.prison_to_probation_update_queue.access_key_id
    secret_access_key = module.prison_to_probation_update_queue.secret_access_key
    sqs_ptpu_url      = module.prison_to_probation_update_queue.sqs_id
    sqs_ptpu_arn      = module.prison_to_probation_update_queue.sqs_arn
    sqs_ptpu_name     = module.prison_to_probation_update_queue.sqs_name
  }
}

resource "kubernetes_secret" "prison_to_probation_update_dead_letter_queue" {
  metadata {
    name      = "ptpu-sqs-dl-instance-output"
    namespace = "prison-to-probation-update-dev"
  }

  data = {
    access_key_id     = module.prison_to_probation_update_dead_letter_queue.access_key_id
    secret_access_key = module.prison_to_probation_update_dead_letter_queue.secret_access_key
    sqs_ptpu_url      = module.prison_to_probation_update_dead_letter_queue.sqs_id
    sqs_ptpu_arn      = module.prison_to_probation_update_dead_letter_queue.sqs_arn
    sqs_ptpu_name     = module.prison_to_probation_update_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prison_to_probation_update_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prison_to_probation_update_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"IMPRISONMENT_STATUS-CHANGED\", \"SENTENCE_DATES-CHANGED\", \"BOOKING_NUMBER-CHANGED\", \"CONFIRMED_RELEASE_DATE-CHANGED\"] }"
}

