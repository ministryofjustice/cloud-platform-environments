module "events_sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.8.0"

  topic_display_name = "offender-management-staging-events"
  encrypt_sns_kms    = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "events_sns_topic" {
  for_each = local.dev_namespaces

  metadata {
    name      = "events-sns-topic"
    namespace = each.key
  }

  data = {
    access_key_id     = module.events_sns_topic.access_key_id
    secret_access_key = module.events_sns_topic.secret_access_key
    topic_name        = module.events_sns_topic.topic_name
    topic_arn         = module.events_sns_topic.topic_arn
  }
}
