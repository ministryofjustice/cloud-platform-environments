module "application-events-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "application-events"
  encrypt_sqs_kms = true
  message_retention_seconds = 1209600

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.application-events-dlq.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "application-events-queue" {
  metadata {
    name      = "application-events-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.application-events-queue.sqs_id
    sqs_name = module.application-events-queue.sqs_name
    sqs_arn  = module.application-events-queue.sqs_arn
  }
}

# Duplicate the secret in Review staging which polls for messages from SQS
resource "kubernetes_secret" "application-events-queue-cross-namespace" {
  metadata {
    name      = "application-events-queue"
    namespace = "laa-review-criminal-legal-aid-staging"
  }

  data = {
    sqs_id   = module.application-events-queue.sqs_id
    sqs_name = module.application-events-queue.sqs_name
    sqs_arn  = module.application-events-queue.sqs_arn
  }
}

resource "aws_sqs_queue_policy" "events-sns-to-application-events-queue-policy" {
  queue_url = module.application-events-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.application-events-queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": { "Service": "sns.amazonaws.com" },
          "Resource": "${module.application-events-queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition": {
            "ArnEquals": {
              "aws:SourceArn": "${module.application-events-sns-topic.topic_arn}"
            }
          }
        }
      ]
  }
  EOF
}
