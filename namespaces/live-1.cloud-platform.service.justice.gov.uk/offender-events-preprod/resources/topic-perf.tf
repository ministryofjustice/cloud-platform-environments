module "probation_offender_events_perf" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.1"
  team_name          = var.team_name
  topic_display_name = "probation-offender-events-perf"
  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "probation_offender_events_perf" {
  metadata {
    name      = "probation-offender-events-topic-perf"
    namespace = var.namespace
  }
  data = {
    access_key_id     = module.probation_offender_events_perf.access_key_id
    secret_access_key = module.probation_offender_events_perf.secret_access_key
    topic_arn         = module.probation_offender_events_perf.topic_arn
  }
}
