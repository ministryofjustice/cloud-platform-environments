module "court-case-events-fifo-topic" {
  source = "github.com/sameermoj/cloud-platform-terraform-sns-topic/tree/PIC-4008"

  # Configuration
  topic_display_name = "court-case-events.fifo"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_ssm_parameter" "param-store-topic-arn" {
  type        = "String"
  name        = "/${var.namespace}/court-case-events-fifo-topic"
  value       = module.court-case-events-fifo-topic.topic_arn
  description = "SNS FIFO topic ARN for court-case-events."

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

resource "kubernetes_secret" "court-case-events" {
  metadata {
    name      = "court-case-events-fifo-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.court-case-events-fifo-topic.topic_arn
  }
}
