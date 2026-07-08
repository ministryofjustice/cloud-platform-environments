data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-453cac1179377186788c5fcd12525870"
}

module "pathfinder_api_queue_for_probation_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "pathfinder_api_queue_for_probation_events"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.pathfinder_api_queue_for_probation_events_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "pathfinder_api_queue_for_probation_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "pathfinder_api_queue_for_probation_events_dl"
  encrypt_sqs_kms = "true"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "pathfinder_api_queue_for_probation_events_policy" {
  queue_url = module.pathfinder_api_queue_for_probation_events.sqs_id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "${module.pathfinder_api_queue_for_probation_events.sqs_arn}/SQSDefaultPolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "*"},
      "Action": "SQS:SendMessage",
      "Resource": "${module.pathfinder_api_queue_for_probation_events.sqs_arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${data.aws_sns_topic.probation-offender-events.arn}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "pathfinder_api_probation_subscription" {
  provider  = aws.london
  topic_arn = data.aws_sns_topic.probation-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.pathfinder_api_queue_for_probation_events.sqs_arn

  filter_policy = jsonencode({
    eventType = ["OFFENDER_CHANGED"]
  })
}

resource "kubernetes_secret" "pathfinder_api_queue_for_probation_events" {
  metadata {
    name      = "probation-events-pathfinder-api-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pathfinder_api_queue_for_probation_events.sqs_id
    sqs_queue_arn  = module.pathfinder_api_queue_for_probation_events.sqs_arn
    sqs_queue_name = module.pathfinder_api_queue_for_probation_events.sqs_name
  }
}

resource "kubernetes_secret" "pathfinder_api_queue_for_probation_events_dead_letter_queue" {
  metadata {
    name      = "probation-events-pathfinder-api-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pathfinder_api_queue_for_probation_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.pathfinder_api_queue_for_probation_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.pathfinder_api_queue_for_probation_events_dead_letter_queue.sqs_name
  }
}