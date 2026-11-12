data "aws_sns_topic" "manage_soc_cases_api_probation_offender_events" {
  name = "cloud-platform-Digital-Prison-Services-c2d997878cd24eef94e60f1404977153"
}

module "manage_soc_cases_api_probation_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name                  = "manage_soc_cases_api_probation_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.manage_soc_cases_api_probation_offender_events_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "Sec-and-Int"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

}

module "manage_soc_cases_api_probation_offender_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name        = "manage_soc_cases_api_probation_offender_events_dlq"
  encrypt_sqs_kms = "true"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "Sec-and-Int"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

}

resource "aws_sqs_queue_policy" "manage_soc_cases_api_probation_offender_events_queue_policy" {
  queue_url = module.manage_soc_cases_api_probation_offender_events_queue.sqs_id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${module.manage_soc_cases_api_probation_offender_events_queue.sqs_arn}/SQSDefaultPolicy"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Resource  = module.manage_soc_cases_api_probation_offender_events_queue.sqs_arn
        Action    = "SQS:SendMessage"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = data.aws_sns_topic.manage_soc_cases_api_probation_offender_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "manage_soc_cases_api_probation_offender_events_subscription" {
  topic_arn = data.aws_sns_topic.manage_soc_cases_api_probation_offender_events.arn
  protocol  = "sqs"
  endpoint  = module.manage_soc_cases_api_probation_offender_events_queue.sqs_arn

  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_CHANGED"
    ]
  })
}

resource "kubernetes_secret" "manage_soc_cases_api_probation_offender_events_queue" {
  metadata {
    name      = "manage-soc-cases-api-probation-events-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.manage_soc_cases_api_probation_offender_events_queue.sqs_id
    sqs_queue_arn  = module.manage_soc_cases_api_probation_offender_events_queue.sqs_arn
    sqs_queue_name = module.manage_soc_cases_api_probation_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "manage_soc_cases_api_probation_offender_events_dlq" {
  metadata {
    name      = "manage-soc-cases-api-probation-events-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.manage_soc_cases_api_probation_offender_events_dlq.sqs_id
    sqs_queue_arn  = module.manage_soc_cases_api_probation_offender_events_dlq.sqs_arn
    sqs_queue_name = module.manage_soc_cases_api_probation_offender_events_dlq.sqs_name
  }
}
