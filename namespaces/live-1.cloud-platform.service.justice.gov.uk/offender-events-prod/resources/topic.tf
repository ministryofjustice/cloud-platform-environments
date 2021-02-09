module "offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.1"

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
    namespace = "offender-case-notes-prod"
  }

  data = {
    access_key_id     = module.offender_events.access_key_id
    secret_access_key = module.offender_events.secret_access_key
    topic_arn         = module.offender_events.topic_arn
  }
}

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

resource "kubernetes_secret" "prison_data_compliance" {
  metadata {
    name      = "offender-events-topic"
    namespace = "prison-data-compliance-prod"
  }

  data = {
    access_key_id     = module.offender_events.access_key_id
    secret_access_key = module.offender_events.secret_access_key
    topic_arn         = module.offender_events.topic_arn
  }
}

module "offender_assessments_events" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.1"
  team_name          = var.team_name
  topic_display_name = "offender-assessments-events"
  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_assessments_events" {
  metadata {
    name      = "offender-assessments-events-topic"
    namespace = var.namespace
  }
  data = {
    access_key_id     = module.offender_assessments_events.access_key_id
    secret_access_key = module.offender_assessments_events.secret_access_key
    topic_arn         = module.offender_assessments_events.topic_arn
  }
}