module "court_case_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.2"

  team_name          = var.team_name
  topic_display_name = "court-case-events"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court_case_events" {
  metadata {
    name      = "court-case-events-topic"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.court_case_events.access_key_id
    secret_access_key = module.court_case_events.secret_access_key
    topic_arn         = module.court_case_events.topic_arn
  }
}

