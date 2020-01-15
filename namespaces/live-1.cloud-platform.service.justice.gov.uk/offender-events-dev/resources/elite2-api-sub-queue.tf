module "elite2_api_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "elite2_api_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.elite2_api_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "elite2_api_events_queue_policy" {
  queue_url = module.elite2_api_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.elite2_api_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.elite2_api_events_queue.sqs_arn}",
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

module "elite2_api_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "elite2_api_events_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elite2_api_events_queue" {
  metadata {
    name      = "elite2api-events-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.elite2_api_events_queue.access_key_id
    secret_access_key = module.elite2_api_events_queue.secret_access_key
    sqs_ocne_url      = module.elite2_api_events_queue.sqs_id
    sqs_ocne_arn      = module.elite2_api_events_queue.sqs_arn
    sqs_ocne_name     = module.elite2_api_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "elite2_api_events_dead_letter_queue" {
  metadata {
    name      = "elite2api-events-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.elite2_api_events_dead_letter_queue.access_key_id
    secret_access_key = module.elite2_api_events_dead_letter_queue.secret_access_key
    sqs_ocne_url      = module.elite2_api_events_dead_letter_queue.sqs_id
    sqs_ocne_arn      = module.elite2_api_events_dead_letter_queue.sqs_arn
    sqs_ocne_name     = module.elite2_api_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "elite2_api_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.elite2_api_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"DATA_COMPLIANCE_DELETE-OFFENDER\"]}"
}
