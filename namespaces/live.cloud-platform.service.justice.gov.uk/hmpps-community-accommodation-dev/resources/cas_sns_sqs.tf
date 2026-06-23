# SNS Topics

module "sns_topic_fileupload" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"
  topic_display_name = "${var.namespace}-sns"

  encrypt_sns_kms             = true
  fifo_topic                  = false
  content_based_deduplication = false

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace
}


# Kubernetes Secrets for SNS Topics

resource "kubernetes_secret" "fileupload_sns" {
  metadata {
    name      = "fileupload-sns-topic"
    namespace = var.namespace
  }
  data = {
    topic_arn = module.sns_topic_fileupload.topic_arn
  }
}

resource "aws_sns_topic_subscription" "queue" {
  topic_arn     = module.sns_topic.topic_arn
  endpoint      = module.sqs_queue.sqs_arn
  protocol      = "sqs"
  filter_policy = "{\"field_name\": [\"string_pattern\", \"string_pattern\", \"...\"]}"
}