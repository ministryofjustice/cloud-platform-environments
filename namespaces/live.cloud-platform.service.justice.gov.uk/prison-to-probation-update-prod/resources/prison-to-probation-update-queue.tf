resource "aws_sns_topic_subscription" "prison-to-probation-update-queue-subscription" {
  topic_arn = data.aws_sns_topic.prison-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.prison-to-probation-update-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "BOOKING_NUMBER-CHANGED",
      "IMPRISONMENT_STATUS-CHANGED",
    ]
  })
}

resource "aws_sqs_queue_policy" "prison-to-probation-update-queue-policy" {
  queue_url = module.prison-to-probation-update-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "prison-to-probation-update-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "prison-to-probation-update-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prison-to-probation-update-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "prison-to-probation-update"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "prison-to-probation-update-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "prison-to-probation-update-dlq"

  # Tags
  business_unit          = var.business_unit
  application            = "prison-to-probation-update"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "prison-to-probation-update-queue-secret" {
  metadata {
    name      = "prison-to-probation-update-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.prison-to-probation-update-queue.sqs_name
  }
}

resource "kubernetes_secret" "prison-to-probation-update-dlq-secret" {
  metadata {
    name      = "prison-to-probation-update-dlq"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.prison-to-probation-update-dlq.sqs_name
  }
}

data "aws_iam_policy_document" "sqs_queue_policy_document" {
  statement {
    sid     = "PrisonOffenderEventsToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_sns_topic.prison-offender-events.arn]
    }
    resources = ["*"]
  }
}