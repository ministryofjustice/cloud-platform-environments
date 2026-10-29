
module "payment_service_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "payment-service"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600 # 14 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.payment_service_dead_letter_queue.sqs_arn
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

module "payment_service_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "payment-service-dlq"
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

resource "aws_sqs_queue_policy" "payment_service_queue_policy" {
  queue_url = module.payment_service_queue.sqs_id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${module.payment_service_queue.sqs_arn}/SQSDefaultPolicy"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Resource  = module.payment_service_queue.sqs_arn
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

resource "aws_sns_topic_subscription" "payment_service_subscription" {
  provider  = aws.london
  topic_arn = module.sns_topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.payment_service_queue.sqs_arn

  filter_policy = jsonencode({
    eventType = [
      "cfo.cats.activity.transitioned",
      "cfo.cats.assessment.completed",
      "cfo.cats.induction.created",
      "cfo.cats.pri.ttg.completed",
      "cfo.cats.objective.task.completed",
      "cfo.cats.enrolment.qa.approved"
    ]
  })
}

resource "kubernetes_secret" "payment_service_queue" {
  metadata {
    name      = "payment-service-sqs-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.payment_service_queue.sqs_id
    sqs_queue_arn  = module.payment_service_queue.sqs_arn
    sqs_queue_name = module.payment_service_queue.sqs_name
    sqs_dlq_url    = module.payment_service_dead_letter_queue.sqs_id
    sqs_dlq_arn    = module.payment_service_dead_letter_queue.sqs_arn
    sqs_dlq_name   = module.payment_service_dead_letter_queue.sqs_name
  }
}
