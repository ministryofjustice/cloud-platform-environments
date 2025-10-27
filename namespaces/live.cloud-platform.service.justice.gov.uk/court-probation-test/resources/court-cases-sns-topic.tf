module "court-cases" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name          = "court-cases"
  encrypt_sns_kms             = true
  fifo_topic                  = true
  content_based_deduplication = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_ssm_parameter" "court-cases-topic-arn" {
  type        = "String"
  name        = "/${var.namespace}/court-cases-topic-arn"
  value       = module.court-cases.topic_arn
  description = "SNS topic ARN for court-cases; use this parameter from other DPS namespaces"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "court-cases" {
  metadata {
    name      = "court-cases-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.court-cases.topic_arn
  }
}
