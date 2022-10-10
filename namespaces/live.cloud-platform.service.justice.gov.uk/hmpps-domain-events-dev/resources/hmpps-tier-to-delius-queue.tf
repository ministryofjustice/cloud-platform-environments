resource "aws_sns_topic_subscription" "hmpps-tier-to-delius-queue-subscription" {
  provider  = aws.probation-integration
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps-tier-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["TIER_CALCULATION_COMPLETED"]
  })
}

module "hmpps-tier-to-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "tier-to-delius"
  sqs_name               = "tier-to-delius-queue"

  message_retention_seconds = 14 * 86400 # 2 weeks
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps-tier-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.probation-integration
  }
}

data "aws_iam_policy_document" "hmpps-tier-to-delius-queue-policy" {
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
    resources = [module.hmpps-tier-to-delius-queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "hmpps-tier-to-delius-queue-policy" {
  queue_url = module.hmpps-tier-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps-tier-to-delius-queue-policy.json
  provider  = aws.probation-integration
}

module "hmpps-tier-to-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "tier-to-delius"
  sqs_name               = "tier-to-delius-dlq"

  providers = {
    aws = aws.probation-integration
  }
}

resource "aws_sqs_queue_policy" "hmpps-tier-to-delius-dlq-policy" {
  queue_url = module.hmpps-tier-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
}

resource "github_actions_environment_secret" "hmpps-tier-to-delius-secrets" {
  for_each = {
    "TIER_TO_DELIUS_SQS_QUEUE_NAME"              = module.hmpps-tier-to-delius-queue.sqs_name
    "TIER_TO_DELIUS_SQS_QUEUE_ACCESS_KEY_ID"     = module.hmpps-tier-to-delius-queue.access_key_id
    "TIER_TO_DELIUS_SQS_QUEUE_SECRET_ACCESS_KEY" = module.hmpps-tier-to-delius-queue.secret_access_key
    "TIER_TO_DELIUS_SQS_DLQ_NAME"                = module.hmpps-tier-to-delius-dlq.sqs_name
    "TIER_TO_DELIUS_SQS_DLQ_ACCESS_KEY_ID"       = module.hmpps-tier-to-delius-dlq.access_key_id
    "TIER_TO_DELIUS_SQS_DLQ_SECRET_ACCESS_KEY"   = module.hmpps-tier-to-delius-dlq.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = "test"
  secret_name     = each.key
  plaintext_value = each.value
}
