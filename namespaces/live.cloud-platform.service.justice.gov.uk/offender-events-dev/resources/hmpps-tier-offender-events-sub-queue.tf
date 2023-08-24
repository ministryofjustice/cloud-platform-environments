module "hmpps_tier_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "hmpps_tier_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  delay_seconds             = 2
  receive_wait_time_seconds = 20

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_tier_offender_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 5
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
    aws = aws.probation-integration
  }
}

resource "aws_sqs_queue_policy" "hmpps_tier_offender_events_queue_policy" {
  queue_url = module.hmpps_tier_offender_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_tier_offender_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_tier_offender_events_queue.sqs_arn}",
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

module "hmpps_tier_offender_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "hmpps_tier_offender_events_queue_dl"
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
    aws = aws.probation-integration
  }
}

resource "kubernetes_secret" "hmpps_tier_offender_events_queue" {
  metadata {
    name      = "hmpps-tier-offender-events-sqs-instance-output"
    namespace = "hmpps-tier-dev"
  }

  data = {
    sqs_ptpu_url  = module.hmpps_tier_offender_events_queue.sqs_id
    sqs_ptpu_arn  = module.hmpps_tier_offender_events_queue.sqs_arn
    sqs_ptpu_name = module.hmpps_tier_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_tier_offender_events_dead_letter_queue" {
  metadata {
    name      = "hmpps-tier-offender-events-sqs-dl-instance-output"
    namespace = "hmpps-tier-dev"
  }
  data = {
    sqs_ptpu_url  = module.hmpps_tier_offender_events_dead_letter_queue.sqs_id
    sqs_ptpu_arn  = module.hmpps_tier_offender_events_dead_letter_queue.sqs_arn
    sqs_ptpu_name = module.hmpps_tier_offender_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_tier_offender_events_subscription" {
  provider      = aws.probation-integration
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.hmpps_tier_offender_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"OFFENDER_MANAGEMENT_TIER_CALCULATION_REQUIRED\"]}"
}
