data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}

resource "aws_sns_topic_subscription" "offender_event_queue_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.offender-event-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.received",
      "prison-offender-events.prisoner.released"
    ]
  })
}

module "offender-event-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "offender-event-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 604800

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.offender-event-dlq.sqs_arn
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

resource "aws_sqs_queue_policy" "offender-event-queue-policy" {
  queue_url = module.offender-event-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.offender-event-queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.offender-event-queue.sqs_arn}",
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

module "offender-event-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "offender-event-dlq"
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
    sqs_queue_url  = module.offender-event-queue.sqs_id
    sqs_queue_arn  = module.offender-event-queue.sqs_arn
    sqs_queue_name = module.offender-event-queue.sqs_name

    sqs_dlq_queue_url  = module.offender-event-dlq.sqs_id
    sqs_dlq_queue_arn  = module.offender-event-dlq.sqs_arn
    sqs_dlq_queue_name = module.offender-event-dlq.sqs_name
  }
}
