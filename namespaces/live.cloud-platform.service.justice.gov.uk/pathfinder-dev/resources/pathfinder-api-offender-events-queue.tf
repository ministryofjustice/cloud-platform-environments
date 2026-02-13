resource "aws_sns_topic_subscription" "pathfinder_api_offender_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.pathfinder_api_offender_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_BOOKING-REASSIGNED",
      "OFFENDER_UPDATED",
      "BOOKING_NUMBER-CHANGED",
      "SENTENCE_DATES-CHANGED",
      "CONFIRMED_RELEASE_DATE-CHANGED"
    ]
  })
}

module "pathfinder_api_offender_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "pathfinder_api_offender_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.pathfinder_api_offender_dlq.sqs_arn
    maxReceiveCount     = 5
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

resource "aws_sqs_queue_policy" "pathfinder_api_offender_queue_policy" {
  queue_url = module.pathfinder_api_offender_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.pathfinder_api_offender_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.pathfinder_api_offender_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
          {
            "ArnEquals":
              {
                "aws:SourceArn": "${data.aws_ssm_parameter.offender-events-topic-arn.value}"
              }
            }
        }
      ]
  }

EOF

}

module "pathfinder_api_offender_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "pathfinder_api_offender_dlq"
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

resource "kubernetes_secret" "pathfinder_api_offender_queue" {
  metadata {
    name      = "sqs-offender-event-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pathfinder_api_offender_queue.sqs_id
    sqs_queue_arn  = module.pathfinder_api_offender_queue.sqs_arn
    sqs_queue_name = module.pathfinder_api_offender_queue.sqs_name
  }
}

resource "kubernetes_secret" "pathfinder_api_offender_dlq" {
  metadata {
    name      = "sqs-offender-event-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pathfinder_api_offender_dlq.sqs_id
    sqs_queue_arn  = module.pathfinder_api_offender_dlq.sqs_arn
    sqs_queue_name = module.pathfinder_api_offender_dlq.sqs_name
  }
}

data "aws_ssm_parameter" "offender-events-topic-arn" {
  name = "/offender-events-${var.environment}/topic-arn"
}
