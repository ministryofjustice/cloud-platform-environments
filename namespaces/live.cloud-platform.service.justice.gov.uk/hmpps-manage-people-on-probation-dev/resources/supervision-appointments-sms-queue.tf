resource "aws_sns_topic_subscription" "supervision-appointments-sms-status-check-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.supervision-appointments-sms-status-check-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "probation.appointment.sms-status-check-requested",
    ]
  })
}

module "supervision-appointments-sms-status-check-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "supervision-appointments-sms-status-check-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.supervision-appointments-sms-status-check-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "hmpps-probation-supervision-appointments-api"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

# Policy to allow SNS -> SQS
data "aws_iam_policy_document" "sqs_queue_policy_document" {
  statement {
    sid     = "DomainEventsToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_sns_topic.hmpps-domain-events.arn]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "supervision-appointments-sms-status-check-queue-policy" {
  queue_url = module.supervision-appointments-sms-status-check-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "supervision-appointments-sms-status-check-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "supervision-appointments-sms-status-check-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "hmpps-probation-supervision-appointments-api"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "supervision-appointments-sms-status-check-dlq-policy" {
  queue_url = module.supervision-appointments-sms-status-check-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "supervision-appointments-sms-status-check-queue-secret" {
  metadata {
    name      = "supervision-appointments-sms-status-check-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.supervision-appointments-sms-status-check-queue.sqs_name
  }
}
