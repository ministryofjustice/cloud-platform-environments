module "intervention_reference_data_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.1"

  team_name          = var.team_name
  topic_display_name = "intervention-reference-data-events"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "intervention_reference_data_events" {
  metadata {
    name      = "intervention-reference-data-events-topic"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.intervention_reference_data_events.access_key_id
    secret_access_key = module.intervention_reference_data_events.secret_access_key
    topic_arn         = module.intervention_reference_data_events.topic_arn
  }
}
