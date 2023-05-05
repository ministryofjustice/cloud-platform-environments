module "application-events-sns-topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.8.0"

  topic_display_name = "datastore-application-events"
  encrypt_sns_kms    = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "application-events-sns-topic" {
  metadata {
    name      = "application-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.application-events-sns-topic.access_key_id
    secret_access_key = module.application-events-sns-topic.secret_access_key
    topic_name        = module.application-events-sns-topic.topic_name
    topic_arn         = module.application-events-sns-topic.topic_arn
  }
}

###
########### SNS subscriptions ###########
###

# TODO: HTTP subscription to be added once review production namespace
# is up and running (needs `/api/events` endpoint).
# Copy and paste subscription block from staging namespace.
