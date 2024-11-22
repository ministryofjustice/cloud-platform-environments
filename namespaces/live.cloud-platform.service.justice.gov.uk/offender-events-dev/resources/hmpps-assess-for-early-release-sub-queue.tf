module "afer_probation_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "afer_probation_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.afer_probation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "afer_probation_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "afer_probation_events_queue_dl"
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

resource "aws_sqs_queue_policy" "afer_probation_events_queue_policy" {
  queue_url = module.afer_probation_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.afer_probation_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.afer_probation_events_queue.sqs_arn}",
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

resource "aws_sns_topic_subscription" "afer_probation_events_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.afer_probation_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"OFFENDER_MANAGER_CHANGED\"]}"
}

resource "kubernetes_secret" "hmpps_assess_for_early_release_probation_events_queue" {
  metadata {
    name      = "hmpps-assess-for-early-release-probation-events-sqs-instance-output"
    namespace = "hmpps-assess-for-early-release-dev"
  }

  data = {
    sqs_id   = module.afer_probation_events_queue.sqs_id
    sqs_arn  = module.afer_probation_events_queue.sqs_arn
    sqs_name = module.afer_probation_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_assess_for_early_release_probation_events_dead_letter_queue" {
  metadata {
    name      = "hmpps-assess-for-early-release-probation-events-sqs-dl-instance-output"
    namespace = "hmpps-assess-for-early-release-dev"
  }

  data = {
    sqs_id   = module.afer_probation_events_dead_letter_queue.sqs_id
    sqs_arn  = module.afer_probation_events_dead_letter_queue.sqs_arn
    sqs_name = module.afer_probation_events_dead_letter_queue.sqs_name
  }
}
