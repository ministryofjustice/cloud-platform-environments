resource "aws_sns_topic_subscription" "domain_events" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.domain_events_topic_arn.value
  protocol  = "sqs"
  endpoint  = module.domain_events_sqs_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "adjudication.report.created"
    ]
  })
}

module "domain_events_sqs_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment_name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "domain-events-sqs-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.domain_events_sqs_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "domain_events_sqs_queue_policy" {
  queue_url = module.domain_events_sqs_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.domain_events_sqs_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.domain_events_sqs_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.domain_events_topic_arn.value}"
                          }
                        }
        }
      ]
  }
EOF

}

module "domain_events_sqs_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "domain-events-sqs-dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "domain_events_sqs_queue" {
  metadata {
    name      = "domain-events-sqs-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.domain_events_sqs_queue.sqs_id
    sqs_queue_arn  = module.domain_events_sqs_queue.sqs_arn
    sqs_queue_name = module.domain_events_sqs_queue.sqs_name
  }
}

resource "kubernetes_secret" "domain_events_dlq" {
  metadata {
    name      = "domain-events-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.domain_events_sqs_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.domain_events_sqs_dead_letter_queue.sqs_arn
    sqs_queue_name = module.domain_events_sqs_dead_letter_queue.sqs_name
  }
}

data "aws_ssm_parameter" "domain_events_topic_arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}
