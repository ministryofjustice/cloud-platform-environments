######################################## Prison visits notification alerts for visit someone in prison
  
######## This will also the notification service to respond to visit events such as BOOKING and CANCELLATION or CHANGED
######## Main queue

resource "aws_sns_topic_subscription" "hmpps_prison_visits_notification_alerts_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_prison_visits_notification_alerts_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-visit.booked",
      "prison-visit.changed",
      "prison-visit.cancelled",
      "prison-visit-request.approved",
      "prison-visit-booker.visitor-approved"
    ]
  })
}

module "hmpps_prison_visits_notification_alerts_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_notification_alerts_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours
  visibility_timeout_seconds = 120 # 2 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prison_visits_notification_alerts_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "book-a-prison-visit" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_prison_visits_notification_alerts_queue_policy" {
  queue_url = module.hmpps_prison_visits_notification_alerts_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prison_visits_notification_alerts_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prison_visits_notification_alerts_queue.sqs_arn}",
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

module "hmpps_prison_visits_notification_alerts_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prison_visits_notification_alerts_dlq"
  encrypt_sqs_kms = "true"
  message_retention_seconds  = 21600 # 6 hours
  visibility_timeout_seconds = 120 # 2 minutes

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "book-a-prison-visit" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

########  Secrets

resource "kubernetes_secret" "hmpps_prison_visits_notification_alerts_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-notification-alerts-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-dev"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_notification_alerts_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_notification_alerts_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_notification_alerts_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_notification_alerts_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-hmpps-prison-visits-notification-alerts-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-dev"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_notification_alerts_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_notification_alerts_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_notification_alerts_dead_letter_queue.sqs_name
  }
}