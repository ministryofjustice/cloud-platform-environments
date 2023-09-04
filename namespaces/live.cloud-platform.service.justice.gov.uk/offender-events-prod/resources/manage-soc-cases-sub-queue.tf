module "manage_soc_cases_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "manage_soc_cases_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.manage_soc_cases_offender_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

  providers = {
    aws = aws.london
  }
}

module "manage_soc_cases_probation_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "manage_soc_cases_probation_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.manage_soc_cases_probation_offender_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "manage_soc_cases_offender_events_queue_policy" {
  queue_url = module.manage_soc_cases_offender_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.manage_soc_cases_offender_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.manage_soc_cases_offender_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.offender_events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sqs_queue_policy" "manage_soc_cases_probation_offender_events_queue_policy" {
  queue_url = module.manage_soc_cases_probation_offender_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.manage_soc_cases_probation_offender_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.manage_soc_cases_probation_offender_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.probation_offender_events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF
}

module "manage_soc_cases_offender_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "manage_soc_cases_offender_events_queue_dl"
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

module "manage_soc_cases_probation_offender_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "manage_soc_cases_probation_offender_events_dlq"
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

resource "kubernetes_secret" "manage_soc_cases_offender_events_queue" {
  metadata {
    name      = "manage-soc-cases-offender-events-sqs-instance-output"
    namespace = "manage-soc-cases-prod"
  }

  data = {
    sqs_id   = module.manage_soc_cases_offender_events_queue.sqs_id
    sqs_arn  = module.manage_soc_cases_offender_events_queue.sqs_arn
    sqs_name = module.manage_soc_cases_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "manage_soc_cases_probation_offender_events_queue" {
  metadata {
    name      = "manage-soc-cases-probation-offender-events-sqs-instance-output"
    namespace = "manage-soc-cases-prod"
  }

  data = {
    sqs_id   = module.manage_soc_cases_probation_offender_events_queue.sqs_id
    sqs_arn  = module.manage_soc_cases_probation_offender_events_queue.sqs_arn
    sqs_name = module.manage_soc_cases_probation_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "manage_soc_cases_offender_events_dead_letter_queue" {
  metadata {
    name      = "manage-soc-cases-offender-events-sqs-dl-instance-output"
    namespace = "manage-soc-cases-prod"
  }

  data = {
    sqs_id   = module.manage_soc_cases_offender_events_dead_letter_queue.sqs_id
    sqs_arn  = module.manage_soc_cases_offender_events_dead_letter_queue.sqs_arn
    sqs_name = module.manage_soc_cases_offender_events_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "manage_soc_cases_probation_offender_events_dead_letter_queue" {
  metadata {
    name      = "manage-soc-cases-probation-offender-events-sqs-dl-instance-output"
    namespace = "manage-soc-cases-prod"
  }

  data = {
    sqs_id   = module.manage_soc_cases_probation_offender_events_dead_letter_queue.sqs_id
    sqs_arn  = module.manage_soc_cases_probation_offender_events_dead_letter_queue.sqs_arn
    sqs_name = module.manage_soc_cases_probation_offender_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "manage_soc_cases_offender_events_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.manage_soc_cases_offender_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"OFFENDER_BOOKING-REASSIGNED\", \"SENTENCE_DATES-CHANGED\", \"BED_ASSIGNMENT_HISTORY-INSERTED\", \"BOOKING_NUMBER-CHANGED\", \"CONFIRMED_RELEASE_DATE-CHANGED\", \"OFFENDER-UPDATED\"]}"
}

resource "aws_sns_topic_subscription" "manage_soc_cases_probation_offender_events_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.manage_soc_cases_probation_offender_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"OFFENDER_CHANGED\"]}"
}
