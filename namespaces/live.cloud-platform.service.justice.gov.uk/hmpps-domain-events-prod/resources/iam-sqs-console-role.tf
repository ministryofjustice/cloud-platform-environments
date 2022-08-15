locals {
  managed_queues = [
    module.workforce_allocation_queue.sqs_arn,
    module.workforce_allocation_dlq.sqs_arn,
    module.pre_sentence_report_queue.sqs_arn,
    module.pre_sentence_report_dlq.sqs_arn,
  ]
}

data "aws_iam_policy_document" "sqs_mgmt_common_policy_document" {
  for_each = toset(local.managed_queues)
  statement {
    sid    = "QueueToConsumer"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::050243167760:role/delius-prod-ecs-sqs-consumer",
        aws_iam_role.sqs_mgmt_role.arn
      ]
    }
    resources = [each.value]
  }
  statement {
    sid    = "QueueManagement"
    effect = "Allow"
    actions = [
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueueTags",
      "sqs:ListQueues",
      "sqs:PurgeQueue",
      "sqs:SetQueueAttributes"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.sqs_mgmt_role.arn]
    }
    resources = [each.value]
  }
  statement {
    sid     = "ListQueues"
    effect  = "Allow"
    actions = ["sqs:ListQueues"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.sqs_mgmt_role.arn]
    }
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sqs_mgmt_policy_document" {
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
    resources = local.managed_queues
  }
  statement {
    sid    = "SQSListQueues"
    effect = "Allow"
    actions = [
      "sqs:ListQueues",
    ]
    resources = ["*"]
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

data "aws_iam_policy_document" "sqs_mgmt_assume_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::570551521311:root"] # hmpps-probation
    }
  }
}

resource "aws_iam_role" "sqs_mgmt_role" {
  name               = "${var.namespace}-sqs-mgmt"
  assume_role_policy = data.aws_iam_policy_document.sqs_mgmt_assume_role_policy_document.json
  inline_policy {
    policy = data.aws_iam_policy_document.sqs_mgmt_policy_document.json
  }
}

