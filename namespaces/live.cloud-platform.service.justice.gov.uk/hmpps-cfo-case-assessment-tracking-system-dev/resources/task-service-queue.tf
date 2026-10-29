/*
 * task-service SQS queue + dead-letter queue, subscribed to the SNS topic in sns.tf.
 *
 * The filter_policy eventType values below are DRAFT names using the scheme
 * cfo.cats.<entity>.<action> - confirm them with the team before go-live.
 * List a shared event type in more than one queue to fan it out to several.
 */
module "task_service_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "task-service"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600 # 14 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.task_service_dead_letter_queue.sqs_arn
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

module "task_service_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "task-service-dlq"
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

resource "aws_sqs_queue_policy" "task_service_queue_policy" {
  queue_url = module.task_service_queue.sqs_id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${module.task_service_queue.sqs_arn}/SQSDefaultPolicy"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Resource  = module.task_service_queue.sqs_arn
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

resource "aws_sns_topic_subscription" "task_service_subscription" {
  provider  = aws.london
  topic_arn = module.sns_topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.task_service_queue.sqs_arn

  filter_policy = jsonencode({
    eventType = [
      "cfo.cats.activity.transitioned",
      "cfo.cats.assessment.completed",
      "cfo.cats.bio.completed",
      "cfo.cats.target.updated",
      "cfo.cats.pri.assigned",
      "cfo.cats.participant.created",
      "cfo.cats.participant.engaged",
      "cfo.cats.participant.transitioned",
      "cfo.cats.participant.sync.requested",
      "cfo.cats.objective.task.completed",
      "cfo.cats.dipsample.finalised",
      "cfo.cats.dipsample.verification.requested"
    ]
  })
}

resource "kubernetes_secret" "task_service_queue" {
  metadata {
    name      = "task-service-sqs-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.task_service_queue.sqs_id
    sqs_queue_arn  = module.task_service_queue.sqs_arn
    sqs_queue_name = module.task_service_queue.sqs_name
    sqs_dlq_url    = module.task_service_dead_letter_queue.sqs_id
    sqs_dlq_arn    = module.task_service_dead_letter_queue.sqs_arn
    sqs_dlq_name   = module.task_service_dead_letter_queue.sqs_name
  }
}
