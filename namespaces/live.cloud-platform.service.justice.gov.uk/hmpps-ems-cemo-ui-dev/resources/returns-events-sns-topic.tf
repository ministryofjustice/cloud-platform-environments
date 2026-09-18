module "returns_events_sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  topic_display_name          = "returns-events"
  encrypt_sns_kms             = true
  fifo_topic                  = true
  content_based_deduplication = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "returns_events_sns_topic" {
  metadata {
    name      = "returns-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_name = module.returns_events_sns_topic.topic_name
    topic_arn  = module.returns_events_sns_topic.topic_arn
  }
}

resource "aws_ssm_parameter" "returns_events_sns_topic_arn" {
  provider    = aws.london
  type        = "String"
  name        = "/${var.namespace}/returns-events-topic-arn"
  value       = module.returns_events_sns_topic.topic_arn
  description = "Returns events SNS topic ARN"
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_sns_topic_subscription" "returns_events_fifo_subscription" {
  provider             = aws.london
  topic_arn            = module.returns_events_sns_topic.topic_arn
  protocol             = "sqs"
  endpoint             = module.returns_events_fifo_queue.sqs_arn
  raw_message_delivery = true
}
