######################################## Prison visits allocation events for visit someone in prison
######## This will allow the visit-allocation-api to monitor for conviction status changes on prisoners to enable VO / PVO processing
######## Main queue

resource "aws_sns_topic_subscription" "hmpps_prison_visits_allocation_events_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_prison_visits_allocation_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prisoner-offender-search.prisoner.convicted-status-changed",
      "prisoner-offender-search.prisoner.received",
      "prison-offender-events.prisoner.merged",
      "prison-offender-events.prisoner.booking.moved",
      "prison-visit.booked",
      "prison-visit.cancelled"
    ]
  })
}

module "hmpps_prison_visits_allocation_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_allocation_events_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 10800 # 3 hours
  visibility_timeout_seconds = 120   # 10 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prison_visits_allocation_events_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_prison_visits_allocation_events_queue_policy" {
  queue_url = module.hmpps_prison_visits_allocation_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prison_visits_allocation_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prison_visits_allocation_events_queue.sqs_arn}",
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

######## Dead letter queue

module "hmpps_prison_visits_allocation_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prison_visits_allocation_events_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

########  Secrets

resource "kubernetes_secret" "hmpps_prison_visits_allocation_events_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-allocation-events-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_allocation_events_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_allocation_events_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_allocation_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_allocation_events_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-hmpps-prison-visits-allocation-events-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_allocation_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_allocation_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_allocation_events_dead_letter_queue.sqs_name
  }
}
