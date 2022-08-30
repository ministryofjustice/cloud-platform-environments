module "pre_sentence_report_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "pre_sentence_report_hmpps_queue"
  message_retention_seconds = 14 * 86400 # 2 weeks
  namespace                 = var.namespace
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.pre_sentence_report_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "pre_sentence_report_queue_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
  ]
  statement {
    sid     = "TopicToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.hmpps-domain-events.topic_arn]
    }
    resources = [module.pre_sentence_report_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "pre_sentence_report_queue_policy" {
  queue_url = module.pre_sentence_report_queue.sqs_id
  policy    = data.aws_iam_policy_document.pre_sentence_report_queue_policy.json
}

module "pre_sentence_report_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "pre_sentence_report_hmpps_dlq"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "pre_sentence_report_dlq_policy" {
  queue_url = module.pre_sentence_report_dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
}

resource "aws_sns_topic_subscription" "pre_sentence_report_queue_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.pre_sentence_report_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["pre-sentence.report.completed"]
  })
}
