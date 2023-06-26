locals {
  managed_sqs_queues = [
    module.person-search-index-from-delius-person-queue,
    module.person-search-index-from-delius-person-dlq,
    module.person-search-index-from-delius-contact-queue,
    module.person-search-index-from-delius-contact-dlq,
    module.refer-and-monitor-and-delius-queue,
    module.refer-and-monitor-and-delius-dlq,
    module.unpaid-work-and-delius-queue,
    module.unpaid-work-and-delius-dlq,
    module.make-recall-decisions-and-delius-queue,
    module.make-recall-decisions-and-delius-dlq,
    module.custody-key-dates-and-delius-queue,
    module.custody-key-dates-and-delius-dlq,
    module.pre-sentence-reports-to-delius-queue,
    module.pre-sentence-reports-to-delius-dlq,
    module.prison-case-notes-to-probation-queue,
    module.prison-case-notes-to-probation-dlq,
    module.prison-custody-status-to-delius-queue,
    module.prison-custody-status-to-delius-dlq,
    module.risk-assessment-scores-to-delius-queue,
    module.risk-assessment-scores-to-delius-dlq,
    module.tier-to-delius-queue,
    module.tier-to-delius-dlq,
  ]
}

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
  statement {
    sid     = "ProbationOffenderEventsToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_sns_topic.probation-offender-events.arn]
    }
    resources = ["*"]
  }
  statement {
    sid    = "QueueManagementRead"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueueTags",
      "sqs:ListQueues",
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.console_role.arn]
    }
    resources = ["*"]
  }
  statement {
    sid    = "QueueManagementWrite"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.console_role.arn]
    }
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sqs_console_role_policy_document" {
  statement {
    sid    = "QueueManagementList"
    effect = "Allow"
    actions = [
      "sqs:ListQueues",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "QueueManagementRead"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueueTags",
    ]
    resources = local.managed_sqs_queues[*].sqs_arn
  }
  statement {
    sid    = "QueueManagementWrite"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    resources = local.managed_sqs_queues[*].sqs_arn
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
    policy = data.aws_iam_policy_document.sqs_console_role_policy_document.json
  }
}

