/*
 * telemetry-service SQS queue + dead-letter queue, subscribed to the SNS topic in sns.tf.
 *
 * The filter_policy eventType values below are DRAFT names using the scheme
 * cfo.cats.<entity>.<action> - confirm them with the team before go-live.
 * List a shared event type in more than one queue to fan it out to several.
 */
module "telemetry_service_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "telemetry-service"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600 # 14 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.telemetry_service_dead_letter_queue.sqs_arn
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

module "telemetry_service_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "telemetry-service-dlq"
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

resource "aws_sqs_queue_policy" "telemetry_service_queue_policy" {
  queue_url = module.telemetry_service_queue.sqs_id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${module.telemetry_service_queue.sqs_arn}/SQSDefaultPolicy"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Resource  = module.telemetry_service_queue.sqs_arn
        Action    = "SQS:SendMessage"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.sns_topic.topic_arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "telemetry_service_subscription" {
  provider  = aws.london
  topic_arn = module.sns_topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.telemetry_service_queue.sqs_arn

  filter_policy = jsonencode({
    eventType = [
      "cfo.cats.telemetry.tracked"
    ]
  })
}

resource "kubernetes_secret" "telemetry_service_queue" {
  metadata {
    name      = "telemetry-service-sqs-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.telemetry_service_queue.sqs_id
    sqs_queue_arn  = module.telemetry_service_queue.sqs_arn
    sqs_queue_name = module.telemetry_service_queue.sqs_name
    sqs_dlq_url    = module.telemetry_service_dead_letter_queue.sqs_id
    sqs_dlq_arn    = module.telemetry_service_dead_letter_queue.sqs_arn
    sqs_dlq_name   = module.telemetry_service_dead_letter_queue.sqs_name
  }
}
