resource "aws_sns_topic_subscription" "prisoner_event_queue_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner-event-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.merged"
    ]
  })
}

module "prisoner-event-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "prisoner-event-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner-event-dlq.sqs_arn
    maxReceiveCount     = 3
  })

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prisoner-event-dlq"
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

resource "kubernetes_secret" "prisoner-event-queue" {
  metadata {
    name      = "sqs-prisoner-event-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner-event-queue.sqs_id
    sqs_queue_arn  = module.prisoner-event-queue.sqs_arn
    sqs_queue_name = module.prisoner-event-queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner-event-queue-dlq" {
  metadata {
    name      = "sqs-prisoner-event-queue-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner-event-dlq.sqs_id
    sqs_queue_arn  = module.prisoner-event-dlq.sqs_arn
    sqs_queue_name = module.prisoner-event-dlq.sqs_name
  }
}
