module "probation_offender_events" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.1"
  team_name          = var.team_name
  topic_display_name = "probation-offender-events"
  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "probation_offender_events" {
  metadata {
    name      = "probation-offender-events-topic"
    namespace = var.namespace
  }
  data = {
    access_key_id     = module.probation_offender_events.access_key_id
    secret_access_key = module.probation_offender_events.secret_access_key
    topic_arn         = module.probation_offender_events.topic_arn
  }
}
