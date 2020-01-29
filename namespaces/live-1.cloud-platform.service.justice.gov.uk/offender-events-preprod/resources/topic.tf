module "offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.0"

  team_name          = var.team_name
  topic_display_name = "offender-events"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_events" {
  metadata {
    name      = "offender-events-topic"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.offender_events.access_key_id
    secret_access_key = module.offender_events.secret_access_key
    topic_arn         = module.offender_events.topic_arn
  }
}

resource "kubernetes_secret" "offender_case_notes" {
  metadata {
    name      = "offender-events-topic"
    namespace = "offender-case-notes-preprod"
  }

  data = {
    access_key_id     = module.offender_events.access_key_id
    secret_access_key = module.offender_events.secret_access_key
    topic_arn         = module.offender_events.topic_arn
  }
}

resource "kubernetes_secret" "prison-data-compliance" {
  metadata {
    name      = "offender-events-topic"
    namespace = "prison-data-compliance-preprod"
  }

  data = {
    access_key_id     = module.offender_events.access_key_id
    secret_access_key = module.offender_events.secret_access_key
    topic_arn         = module.offender_events.topic_arn
  }
}
