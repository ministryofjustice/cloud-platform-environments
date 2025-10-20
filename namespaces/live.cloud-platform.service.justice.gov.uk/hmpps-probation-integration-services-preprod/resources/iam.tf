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
  statement {
    sid     = "ProbationOffenderEventsProdToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_sns_topic.probation-offender-events-prod.arn]
    }
    resources = ["*"]
  }
  statement {
    sid     = "CourtTopicToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_ssm_parameter.court-topic.value]
    }
    resources = ["*"]
  }
  statement {
      sid     = "ProdCourtTopicToQueue"
      effect  = "Allow"
      actions = ["sqs:SendMessage"]
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      condition {
        variable = "aws:SourceArn"
        test     = "ArnEquals"
        values   = [data.aws_ssm_parameter.court-topic-prod.value]
      }
      resources = ["*"]
  }
}

# Policies to manage queues e.g. view and redrive messages
# data "aws_sqs_queue" "queues_from_other_namespaces" {
#   for_each = toset([])
#   name = each.value
# }

data "aws_iam_policy_document" "sqs_management_policy_document" {
  for_each = {
    queue = [
      module.community-payback-and-delius-queue.sqs_arn,
      module.esupervision-and-delius-queue.sqs_arn,
      module.suicide-risk-form-and-delius-queue.sqs_arn,
      module.accredited-programmes-and-delius-queue.sqs_arn,
      module.breach-notice-and-delius-queue.sqs_arn,
      module.justice-email-and-delius-queue.sqs_arn,
      module.common-platform-and-delius-queue.sqs_arn,
      module.common-platform-and-delius-fifo-queue.sqs_arn,
      module.prison-identifier-and-delius-queue.sqs_arn,
      module.cas2-and-delius-queue.sqs_arn,
      module.approved-premises-and-delius-queue.sqs_arn,
      module.assessment-summary-and-delius-queue.sqs_arn,
      module.cas3-and-delius-queue.sqs_arn,
      module.court-case-and-delius-queue.sqs_arn,
      module.create-and-vary-a-licence-and-delius-queue.sqs_arn,
      module.custody-key-dates-and-delius-queue.sqs_arn,
      module.make-recall-decisions-and-delius-queue.sqs_arn,
      module.manage-offences-and-delius-queue.sqs_arn,
      module.manage-pom-cases-and-delius-queue.sqs_arn,
      module.opd-and-delius-queue.sqs_arn,
      module.person-search-index-from-delius-contact-keyword-queue.sqs_arn,
      module.person-search-index-from-delius-contact-queue.sqs_arn,
      module.person-search-index-from-delius-person-queue.sqs_arn,
      module.pre-sentence-reports-to-delius-queue.sqs_arn,
      module.prison-case-notes-to-probation-queue.sqs_arn,
      module.prison-custody-status-to-delius-queue.sqs_arn,
      module.prison-identifier-and-delius-queue.sqs_arn,
      module.refer-and-monitor-and-delius-queue.sqs_arn,
      module.risk-assessment-scores-to-delius-queue.sqs_arn,
      module.tier-to-delius-queue.sqs_arn,
      module.unpaid-work-and-delius-queue.sqs_arn,
      module.workforce-allocations-to-delius-queue.sqs_arn,
    ]
    dlq = [
      module.community-payback-and-delius-dlq.sqs_arn,
      module.esupervision-and-delius-dlq.sqs_arn,
      module.suicide-risk-form-and-delius-dlq.sqs_arn,
      module.accredited-programmes-and-delius-dlq.sqs_arn,
      module.breach-notice-and-delius-dlq.sqs_arn,
      module.justice-email-and-delius-dlq.sqs_arn,
      module.common-platform-and-delius-dlq.sqs_arn,
      module.common-platform-and-delius-fifo-dlq.sqs_arn,
      module.prison-identifier-and-delius-dlq.sqs_arn,
      module.cas2-and-delius-dlq.sqs_arn,
      module.approved-premises-and-delius-dlq.sqs_arn,
      module.assessment-summary-and-delius-dlq.sqs_arn,
      module.cas3-and-delius-dlq.sqs_arn,
      module.court-case-and-delius-dlq.sqs_arn,
      module.create-and-vary-a-licence-and-delius-dlq.sqs_arn,
      module.custody-key-dates-and-delius-dlq.sqs_arn,
      module.make-recall-decisions-and-delius-dlq.sqs_arn,
      module.manage-offences-and-delius-dlq.sqs_arn,
      module.manage-pom-cases-and-delius-dlq.sqs_arn,
      module.opd-and-delius-dlq.sqs_arn,
      module.pre-sentence-reports-to-delius-dlq.sqs_arn,
      module.prison-case-notes-to-probation-dlq.sqs_arn,
      module.prison-custody-status-to-delius-dlq.sqs_arn,
      module.prison-identifier-and-delius-dlq.sqs_arn,
      module.refer-and-monitor-and-delius-dlq.sqs_arn,
      module.risk-assessment-scores-to-delius-dlq.sqs_arn,
      module.tier-to-delius-dlq.sqs_arn,
      module.unpaid-work-and-delius-dlq.sqs_arn,
      module.workforce-allocations-to-delius-dlq.sqs_arn,
    ],
    external = [
      data.aws_sqs_queue.hmpps-tier-events-queue.arn,
      data.aws_sqs_queue.hmpps-tier-events-dlq.arn
    ]
    #others = [for queue in data.aws_sqs_queue.queues_from_other_namespaces : { sqs_arn = queue.arn }]
  }
  statement {
    sid    = "ListAndDecrypt"
    effect = "Allow"
    actions = [
      "sqs:ListQueues",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "ReadWrite"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListMessageMoveTasks",
      "sqs:ListQueueTags",
      "sqs:CancelMessageMoveTask",
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:StartMessageMoveTask",
    ]
    resources = each.value[*]
  }
}

resource "aws_iam_policy" "sqs_management_policy" {
  for_each = data.aws_iam_policy_document.sqs_management_policy_document
  name     = "${var.namespace}-${each.key}-policy"
  policy   = each.value.json
}
