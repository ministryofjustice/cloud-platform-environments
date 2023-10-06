module "court-case-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.0"

  # Configuration
  topic_display_name = "court-case-events"
  encrypt_sns_kms    = true

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

resource "kubernetes_secret" "court-case-events" {
  metadata {
    name      = "court-case-events-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.court-case-events.topic_arn
  }
}
