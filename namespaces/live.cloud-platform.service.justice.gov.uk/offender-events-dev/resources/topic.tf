module "offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.4"

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
    namespace = "offender-case-notes-dev"
  }

  data = {
    access_key_id     = module.offender_events.access_key_id
    secret_access_key = module.offender_events.secret_access_key
    topic_arn         = module.offender_events.topic_arn
  }
}

resource "kubernetes_secret" "prison-data-compliance" {
  metadata {
    name      = "offender-events-topic-prison-data-compliance"
    namespace = var.namespace
    # Remove when namespace has been migrated
    # name      = "offender-events-topic"
    # namespace = "prison-data-compliance-dev"
  }

  data = {
    access_key_id     = module.offender_events.access_key_id
    secret_access_key = module.offender_events.secret_access_key
    topic_arn         = module.offender_events.topic_arn
  }
}

module "probation_offender_events" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.4"
  team_name          = var.team_name
  topic_display_name = "probation-offender-events"
  providers          = {
    aws = aws.london
  }
}

module "offender_assessments_events" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.4"
  team_name          = var.team_name
  topic_display_name = "offender-assessments-events"
  providers          = {
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

resource "github_actions_environment_secret" "offender-events-and-delius" {
  for_each = {
    "OFFENDER_EVENTS_AND_DELIUS_AWS_TOPIC_ARN"         = module.probation_offender_events.topic_arn
    "OFFENDER_EVENTS_AND_DELIUS_AWS_ACCESS_KEY_ID"     = module.probation_offender_events.access_key_id
    "OFFENDER_EVENTS_AND_DELIUS_AWS_SECRET_ACCESS_KEY" = module.probation_offender_events.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = "test"
  secret_name     = each.key
  plaintext_value = each.value
}

