module "cpr_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "cpr_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  delay_seconds             = 2
  receive_wait_time_seconds = 20

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cpr_offender_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 5
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

resource "aws_sqs_queue_policy" "cpr_offender_events_queue_policy" {
  queue_url = module.cpr_offender_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cpr_offender_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cpr_offender_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.probation_offender_events.topic_arn}"]
                          }
                        }
        }
      ]
  }

EOF

}

module "cpr_offender_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "cpr_offender_events_dlq"
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

resource "kubernetes_secret" "cpr_offender_events_queue" {
  metadata {
    name      = "cpr_offender_events_queue"
    namespace = "hmpps-person-record-preprod"
  }

  data = {
    sqs_queue_url  = module.cpr_offender_events_queue.sqs_id
    sqs_queue_arn  = module.cpr_offender_events_queue.sqs_arn
    sqs_queue_name = module.cpr_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "cpr_offender_events_dead_letter_queue" {
  metadata {
    name      = "cpr_offender_events_dlq"
    namespace = "hmpps-person-record-preprod"
  }
  data = {
    sqs_queue_url  = module.cpr_offender_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.cpr_offender_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.cpr_offender_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "cpr_offender_events_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.cpr_offender_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"OFFENDER_DETAILS_CHANGED\"] }"
}
