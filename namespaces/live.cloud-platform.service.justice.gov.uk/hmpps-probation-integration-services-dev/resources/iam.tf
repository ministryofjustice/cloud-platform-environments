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
}

# Policies to manage queues e.g. view and redrive messages
data "aws_sqs_queue" "queues_from_other_namespaces" {
  for_each = toset([
    "${var.team_name}-${var.environment_name}-prison-to-probation-update-queue",
    "${var.team_name}-${var.environment_name}-prison-to-probation-update-dlq",
  ])
  name = each.value
}

data "aws_iam_policy_document" "sqs_management_policy_document" {
  for_each = {
    queue = [
      module.cas2-and-delius-queue,
      module.approved-premises-and-delius-queue,
      module.assessment-summary-and-delius-queue,
      module.cas3-and-delius-queue,
      module.court-case-and-delius-queue,
      module.create-and-vary-a-licence-and-delius-queue,
      module.custody-key-dates-and-delius-queue,
      module.make-recall-decisions-and-delius-queue,
      module.manage-offences-and-delius-queue,
      module.manage-pom-cases-and-delius-queue,
      module.opd-and-delius-queue,
      module.person-search-index-from-delius-contact-queue,
      module.person-search-index-from-delius-person-queue,
      module.pre-sentence-reports-to-delius-queue,
      module.prison-case-notes-to-probation-queue,
      module.prison-custody-status-to-delius-queue,
      module.prison-identifier-and-delius-queue,
      module.refer-and-monitor-and-delius-queue,
      module.risk-assessment-scores-to-delius-queue,
      module.tier-to-delius-queue,
      module.unpaid-work-and-delius-queue,
      module.workforce-allocations-to-delius-queue,
    ]
    dlq = [
      module.cas2-and-delius-dlq,
      module.approved-premises-and-delius-dlq,
      module.assessment-summary-and-delius-dlq,
      module.cas3-and-delius-dlq,
      module.court-case-and-delius-dlq,
      module.create-and-vary-a-licence-and-delius-dlq,
      module.custody-key-dates-and-delius-dlq,
      module.make-recall-decisions-and-delius-dlq,
      module.manage-offences-and-delius-dlq,
      module.manage-pom-cases-and-delius-dlq,
      module.opd-and-delius-dlq,
      module.pre-sentence-reports-to-delius-dlq,
      module.prison-case-notes-to-probation-dlq,
      module.prison-custody-status-to-delius-dlq,
      module.prison-identifier-and-delius-dlq,
      module.refer-and-monitor-and-delius-dlq,
      module.risk-assessment-scores-to-delius-dlq,
      module.tier-to-delius-dlq,
      module.unpaid-work-and-delius-dlq,
      module.workforce-allocations-to-delius-dlq,
    ],
    others = [for queue in data.aws_sqs_queue.queues_from_other_namespaces : { sqs_arn = queue.arn }]
  }
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
      "sqs:ListMessageMoveTasks",
      "sqs:ListQueueTags",
    ]
    resources = each.value[*].sqs_arn
  }
  statement {
    sid    = "QueueManagementWrite"
    effect = "Allow"
    actions = [
      "sqs:CancelMessageMoveTask",
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:StartMessageMoveTask",
    ]
    resources = each.value[*].sqs_arn
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

resource "aws_iam_policy" "sqs_management_policy" {
  for_each = data.aws_iam_policy_document.sqs_management_policy_document
  name     = "${var.namespace}-${each.key}-policy"
  policy   = each.value.json
}
