module "court-case-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.9.0"

  topic_display_name = "court-case-events"
  encrypt_sns_kms    = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

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
    access_key_id     = module.court-case-events.access_key_id
    secret_access_key = module.court-case-events.secret_access_key
    topic_arn         = module.court-case-events.topic_arn
  }
}
