## Temporary queue for inspecting messages from the court topic

data "aws_ssm_parameter" "court-topic" {
  name = "/court-probation-prod/topic-arn"
}

module "court-case-matcher-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "court-case-temp-queue"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "court-case-matcher-queue-policy" {
  queue_url = module.court-case-matcher-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.court-case-matcher-queue.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Resource": "${module.court-case-matcher-queue.sqs_arn}",
        "Action": "SQS:SendMessage",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "${data.aws_ssm_parameter.court-topic.value}"
          }
        }
      }
    ]
  }
EOF
}

resource "aws_sns_topic_subscription" "court-case-matcher-topic-subscription" {
  topic_arn = data.aws_ssm_parameter.court-topic.value
  protocol  = "sqs"
  endpoint  = module.court-case-matcher-queue.sqs_arn
}
