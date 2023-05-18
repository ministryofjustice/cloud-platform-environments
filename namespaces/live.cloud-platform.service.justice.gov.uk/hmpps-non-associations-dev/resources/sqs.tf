resource "aws_sns_topic_subscription" "prisoner_event_queue_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner-event-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.merged",
      "prisoner-offender-search.prisoner.received",
      "prisoner-offender-search.prisoner.alerts-updated"
    ]
  })
}

module "prisoner-event-queue" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "prisoner-event-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner-event-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prisoner-event-queue-policy" {
  queue_url = module.prisoner-event-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner-event-queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner-event-queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner-event-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "prisoner-event-dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner-event-queue" {
  metadata {
    name      = "sqs-prisoner-event-queue-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prisoner-event-queue.access_key_id
    secret_access_key = module.prisoner-event-queue.secret_access_key
    sqs_queue_url     = module.prisoner-event-queue.sqs_id
    sqs_queue_arn     = module.prisoner-event-queue.sqs_arn
    sqs_queue_name    = module.prisoner-event-queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner-event-queue-dlq" {
  metadata {
    name      = "sqs-prisoner-event-queue-dlq-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prisoner-event-dlq.access_key_id
    secret_access_key = module.prisoner-event-dlq.secret_access_key
    sqs_queue_url     = module.prisoner-event-dlq.sqs_id
    sqs_queue_arn     = module.prisoner-event-dlq.sqs_arn
    sqs_queue_name    = module.prisoner-event-dlq.sqs_name
  }
}
