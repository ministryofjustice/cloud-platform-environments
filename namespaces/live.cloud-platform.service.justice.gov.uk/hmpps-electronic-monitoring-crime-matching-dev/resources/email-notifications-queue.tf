###
# Creates an SQS queue for storing email notifications.
# Creates a DLQ for failed notifications.
# Creates a policy for processing messages on queue.
# Creates an SQS subscription for the topic to store email notifications for async processing.
###

module "email_notifications_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "email-notifications"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.email_notifications_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "email_notifications_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "email-notifications-dlq"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "email_notifications_queue" {
  metadata {
    name      = "email-notifications-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.email_notifications_queue.sqs_id
    sqs_queue_arn  = module.email_notifications_queue.sqs_arn
    sqs_queue_name = module.email_notifications_queue.sqs_name
  }
}

resource "kubernetes_secret" "email_notifications_dlq" {
  metadata {
    name      = "email-notifications-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.email_notifications_dlq.sqs_id
    sqs_queue_arn  = module.email_notifications_dlq.sqs_arn
    sqs_queue_name = module.email_notifications_dlq.sqs_name
  }
}

data "aws_iam_policy_document" "email_notifications_queue" {
  statement {
    sid     = "AllowEmailNotificationsToQueue"
    effect  = "Allow"
    actions = [
      "sqs:SendMessage",
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "*",
      ]
    }

    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [
        module.email_notifications_topic.topic_arn,
      ]
    }

    resources = [
      "*",
    ]
  }

  statement {
    sid     = "AllowReadDelete"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        "*",
      ]
    }

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = [
      module.email_notifications_queue.sqs_arn,
    ]

    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [
        module.irsa.role_arn,
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "email_notifications" {
  queue_url = module.email_notifications_queue.sqs_id
  policy    = data.aws_iam_policy_document.email_notifications_queue.json
}

data "aws_iam_policy_document" "email_notifications_dlq" {
  statement {
    sid     = "AllowReadDelete"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        "*",
      ]
    }

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = [
      module.email_notifications_dlq.sqs_arn,
    ]

    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [
        module.irsa.role_arn,
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "email_notifications" {
  queue_url = module.email_notifications_dlq.sqs_id
  policy    = data.aws_iam_policy_document.email_notifications_dlq.json
}

resource "aws_sns_topic_subscription" "email_notifications" {
  topic_arn     = module.email_notifications_topic.topic_arn
  endpoint      = module.email_notifications_queue.sqs_arn
  protocol      = "sqs"
}
