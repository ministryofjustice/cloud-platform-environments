module "hmpps-integration-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "integration-api-event-topic"
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
    aws = aws.london_without_default_tags
  }
}

resource "kubernetes_secret" "hmpps-integration-events-secret" {
  metadata {
    name      = "hmpps-integration-events"
    namespace = var.namespace
  }

  data = {  
    sqs_arn  = module.hmpps-integration-events.topic_arn
    sqs_name = module.hmpps-integration-events.topic_name
  }
}