module "em-notification-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configurations
  topic_display_name = "integration-api-em-notification-events-topic"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "hmpps-integration-em-notification-events-secret" {
  metadata {
    name      = "hmpps-integration-em-notification-events-topic"
    namespace = var.namespace
  }

  data = {
    sns_arn      = module.hmpps-integration-events.topic_arn
    sns_name     = module.hmpps-integration-events.topic_name
    sns_irsa_arn = module.integration_api_domain_events_queue.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "em-notification-events-topic-arn" {
  type        = "String"
  name        = "/${var.namespace}/em-notification-events-topic-arn"
  value       = module.em-notification-events.topic_arn
  description = "SNS topic ARN for em notification events; use this parameter from other namespaces"

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}
