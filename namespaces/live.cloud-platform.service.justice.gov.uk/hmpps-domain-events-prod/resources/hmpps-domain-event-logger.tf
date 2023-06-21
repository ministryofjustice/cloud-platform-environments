module "hmpps_domain_event_logger_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_domain_event_logger_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_domain_event_logger_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_domain_event_logger_queue_policy" {
  queue_url = module.hmpps_domain_event_logger_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_domain_event_logger_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_domain_event_logger_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.hmpps-domain-events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

module "hmpps_domain_event_logger_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_domain_event_logger_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_domain_event_logger_queue" {
  metadata {
    name      = "sqs-domain-event-logger-secret"
    namespace = "hmpps-domain-event-logger-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_domain_event_logger_queue.sqs_id
    sqs_queue_arn  = module.hmpps_domain_event_logger_queue.sqs_arn
    sqs_queue_name = module.hmpps_domain_event_logger_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_domain_event_logger_dead_letter_queue" {
  metadata {
    name      = "sqs-domain-event-logger-dlq-secret"
    namespace = "hmpps-domain-event-logger-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_domain_event_logger_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_domain_event_logger_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_domain_event_logger_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_domain_event_logger_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps_domain_event_logger_queue.sqs_arn
}
