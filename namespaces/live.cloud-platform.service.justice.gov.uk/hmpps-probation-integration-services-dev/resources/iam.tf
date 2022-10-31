locals {
  managed_sqs_queues = [
    module.prison-case-notes-to-probation-queue.sqs_arn,
    module.prison-case-notes-to-probation-dlq.sqs_arn,
  ]
}

data "aws_iam_policy_document" "sqs_console_policy_document" {
  statement {
    sid    = "SQS"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueueTags",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:SetQueueAttributes"
    ]
    resources = local.managed_sqs_queues
  }
  statement {
    sid    = "KMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "console_assume_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::570551521311:root"] # hmpps-probation
    }
  }
}

resource "aws_iam_role" "console_role" {
  name               = "${var.namespace}-console"
  assume_role_policy = data.aws_iam_policy_document.console_assume_role_policy_document.json
  inline_policy {
    policy = data.aws_iam_policy_document.sqs_console_policy_document.json
  }
}

