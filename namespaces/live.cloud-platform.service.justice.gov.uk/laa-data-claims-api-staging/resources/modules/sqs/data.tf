/* --SQS Access Control--
The two data sources below control access to SQS by looking up the value in the "namespace" tag
for a specific namespace. */
# data.tf

data "aws_iam_roles" "sqs_subscriber_roles" {
  name_regex = var.sqs_subscriber_roles_regex_filter
}

data "aws_iam_role" "sqs_matching_roles" {
  for_each = toset(local.sqs_matching_role_names)
  name     = each.value
}

# Resource-based policy on the DLQ
data "aws_iam_policy_document" "dlq" {
  # Only the source queue can redrive messages into the DLQ
  statement {
    sid    = "AllowRedriveFromSourceQueue"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [module.dlq.sqs_arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.queue.sqs_arn]
    }
  }

  # Only IRSA roles tagged with an allowed namespace can read/manage the DLQ
  statement {
    sid    = "AllowIRSAAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [for role in local.sqs_roles_with_namespace_tag : role.arn]
    }
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:PurgeQueue",
    ]
    resources = [module.dlq.sqs_arn]
  }
}

# Resource-based policy on the main queue
data "aws_iam_policy_document" "queue" {
  # Only the SNS topic can send messages
  statement {
    sid    = "AllowSNSSend"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [module.queue.sqs_arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_topic_arn]
    }
  }

  # Only IRSA roles tagged with an allowed namespace can consume
  statement {
    sid    = "AllowIRSAConsume"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [for role in local.sqs_roles_with_namespace_tag : role.arn]
    }
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = [module.queue.sqs_arn]
  }
}