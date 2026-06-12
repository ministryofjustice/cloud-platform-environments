# ── SQS: workflow run event queue ────────────────────────────────────────────

module "log_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  application                = var.application
  sqs_name                   = "log-events"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 300

  business_unit          = var.business_unit
  namespace              = var.namespace
  environment_name       = var.environment_name
  is_production          = var.is_production
  team_name              = var.team_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sns_topic_subscription" "log_events_queue_subscription" {
  topic_arn = module.log_events_topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.log_events_queue.sqs_arn
}

data "aws_iam_policy_document" "log_events_queue_policy" {
  policy_id = "${module.log_events_queue.sqs_arn}/SQSDefaultPolicy"

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [module.log_events_queue.sqs_arn]
    actions   = ["SQS:SendMessage"]

    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.log_events_topic.topic_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "log_events_queue_policy" {
  queue_url = module.log_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.log_events_queue_policy.json
}
