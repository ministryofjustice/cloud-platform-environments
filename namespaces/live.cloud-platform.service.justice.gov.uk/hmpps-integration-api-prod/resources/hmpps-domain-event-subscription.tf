data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}

module "integration_api_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "integration_api_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.integration_api_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "integration_api_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "integration_api_domain_events_queue_dl"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "integration_api_domain_events_queue_policy" {
  queue_url = module.integration_api_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.integration_api_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.integration_api_domain_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sns_topic_subscription" "integration_api_domain_events_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.integration_api_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "probation-case.registration.added",
      "probation-case.registration.updated",
      "probation-case.registration.deleted",
      "probation-case.registration.deregistered",
      "probation-case.engagement.created",
      "probation-case.prison-identifier.added",
      "probation-case.address.created",
      "probation-case.address.updated",
      "probation-case.address.deleted",
      "probation-case.risk-scores.ogrs.manual-calculation",
      "plp.induction-schedule.updated",
      "plp.review-schedule.updated",
      "san.plan-creation-schedule.updated",
      "san.review-schedule.updated",
      "create-and-vary-a-licence.licence.activated",
      "create-and-vary-a-licence.licence.inactivated",
      "person.alert.created",
      "person.alert.changed",
      "person.alert.updated",
      "person.alert.deleted",
      "person.community.manager.allocated",
      "person.community.manager.transferred",
      "person.case-note.created",
      "person.case-note.updated",
      "person.case-note.deleted",
      "prisoner-offender-search.prisoner.created",
      "prisoner-offender-search.prisoner.received",
      "prisoner-offender-search.prisoner.updated",
      "prisoner-offender-search.prisoner.released",
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.contact-added",
      "prison-offender-events.prisoner.contact-approved",
      "prison-offender-events.prisoner.contact-unapproved",
      "prison-offender-events.prisoner.contact-removed",
      "prison-offender-events.prisoner.restriction.changed",
      "prison-offender-events.prisoner.person-restriction.upserted",
      "prison-offender-events.prisoner.person-restriction.deleted",
      "prison-offender-events.prisoner.non-association-detail.changed",
      "prison-offender-events.prisoner.received",
      "calculate-release-dates.prisoner.changed",
      "risk-assessment.scores.ogrs.determined",
      "risk-assessment.scores.rsr.determined",
      "assessment.summary.produced",
      "incentives.iep-review.inserted",
      "incentives.iep-review.updated",
      "incentives.iep-review.deleted",
      "prison-visit.booked",
      "prison-visit.changed",
      "prison-visit.cancelled",
      "adjudication.hearing.created",
      "adjudication.hearingCompleted.created",
      "adjudication.hearing.deleted",
      "adjudication.punishments.created",
      "adjudication.report.created",
      "non-associations.created",
      "non-associations.amended",
      "non-associations.closed",
      "non-associations.deleted",
      "location.inside.prison.created",
      "location.inside.prison.amended",
      "location.inside.prison.deleted",
      "location.inside.prison.deactivated",
      "location.inside.prison.reactivated",
      "location.inside.prison.signed-op-cap.amended"
    ]
  })
}

resource "kubernetes_secret" "integration_api_domain_events_queue" {
  metadata {
    name      = "hmpps-integration-api-domain-events-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id                        = module.integration_api_domain_events_queue.sqs_id
    sqs_arn                       = module.integration_api_domain_events_queue.sqs_arn
    sqs_name                      = module.integration_api_domain_events_queue.sqs_name
    hmpps_domain_events_topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  }
}

resource "kubernetes_secret" "integration_api_domain_events_dead_letter_queue" {
  metadata {
    name      = "hmpps-integration-api-domain-events-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.integration_api_domain_events_dead_letter_queue.sqs_id
    sqs_arn  = module.integration_api_domain_events_dead_letter_queue.sqs_arn
    sqs_name = module.integration_api_domain_events_dead_letter_queue.sqs_name
  }
}
