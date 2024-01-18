######################################## Prison visits event for visit someone in prison
######## hmpps-manage-prison-visits-orchestration service should listen to the configured queue (hmpps_prison_visits_event_queue)
######## Main queue

resource "aws_sns_topic_subscription" "hmpps_prison_visits_event_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_prison_visits_event_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
    ]
  })
}

module "hmpps_prison_visits_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_event_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn
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

resource "aws_sqs_queue_policy" "hmpps_prison_visits_event_queue_policy" {
  queue_url = module.hmpps_prison_visits_event_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prison_visits_event_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prison_visits_event_queue.sqs_arn}",
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

module "hmpps_prison_visits_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "hmpps_prison_visits_event_dlq"
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

resource "kubernetes_secret" "hmpps_prison_visits_event_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-hmpps-prison-visits-event-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_event_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_event_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_event_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_event_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-hmpps-prison-visits-event-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_event_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_event_dead_letter_queue.sqs_name
  }
}