/* --SQS Access Control--
The two data sources below control access to SQS by looking up the value in the "namespace" tag
for a specific namespace. */

data "aws_iam_roles" "sqs_subscriber_roles" {
  name_regex = var.sqs_subscriber_roles_regex_filter
}

data "aws_iam_role" "sqs_matching_roles" {
  for_each = toset(local.sqs_matching_role_names)
  name     = each.value
}

#--DLQ Policy
data "aws_iam_policy_document" "dlq" {
  statement {
    sid    = "Allow"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "sqs:*"
    ]
    resources = [module.dlq.sqs_arn]
  }
}

#--This policy will be constructed from the data sources above and some local transformations to grant SQS access
data "aws_iam_policy_document" "queue" {
  statement {
    sid    = "AllowSend"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [module.queue.sqs_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        for role in local.sqs_roles_with_namespace_tag : role.arn
      ]
    }
  }

  statement {
    sid    = "AllowReadDelete"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [module.queue.sqs_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        for role in local.sqs_roles_with_namespace_tag : role.arn
      ]
    }
  }
}
