######################################## Prison visits event for visit someone in prison
######## hmpps-manage-prison-visits-orchestration service should listen to the configured queue (hmpps_prison_visits_event_queue)
######## for the given fevents (filter_policy configured below)!


######## Main queue

module "hmpps_prison_visits_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "hmpps_prison_visits_event_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
EOF
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
                "aws:SourceArn": "${module.hmpps-domain-events.topic_arn}"
              }
            }
        }
      ]
  }
EOF
}

resource "kubernetes_secret" "hmpps_prison_visits_event_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-event-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-dev"
  }

  data = {
    access_key_id     = module.hmpps_prison_visits_event_queue.access_key_id
    secret_access_key = module.hmpps_prison_visits_event_queue.secret_access_key
    sqs_queue_url     = module.hmpps_prison_visits_event_queue.sqs_id
    sqs_queue_arn     = module.hmpps_prison_visits_event_queue.sqs_arn
    sqs_queue_name    = module.hmpps_prison_visits_event_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_prison_visits_event_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps_prison_visits_event_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "incentives.iep-review.inserted",
      "incentives.iep-review.updated",
      "incentives.iep-review.deleted"
    ]
  })
}

######## Dead letter queue

module "hmpps_prison_visits_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_prison_visits_event_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_event_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-event-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-dev"
  }

  data = {
    access_key_id     = module.hmpps_prison_visits_event_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_prison_visits_event_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_prison_visits_event_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_prison_visits_event_dead_letter_queue.sqs_name
  }
}
