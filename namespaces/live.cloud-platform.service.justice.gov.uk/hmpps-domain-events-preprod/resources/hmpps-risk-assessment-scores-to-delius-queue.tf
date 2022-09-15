resource "aws_sns_topic_subscription" "hmpps-risk-assessment-scores-to-delius-queue-subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps-risk-assessment-scores-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["risk-assessment.scores.rsr.determined"]
  })
}

module "hmpps-risk-assessment-scores-to-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "risk-assessment-scores-to-delius"
  sqs_name               = "risk-assessment-scores-to-delius-queue"

  message_retention_seconds = 14 * 86400 # 2 weeks
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps-risk-assessment-scores-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "hmpps-risk-assessment-scores-to-delius-queue-policy" {
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
    resources = [module.hmpps-risk-assessment-scores-to-delius-queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "hmpps-risk-assessment-scores-to-delius-queue-policy" {
  queue_url = module.hmpps-risk-assessment-scores-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps-risk-assessment-scores-to-delius-queue-policy.json
  provider  = aws.london
}

module "hmpps-risk-assessment-scores-to-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "risk-assessment-scores-to-delius"
  sqs_name               = "risk-assessment-scores-to-delius-dlq"

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps-risk-assessment-scores-to-delius-dlq-policy" {
  queue_url = module.hmpps-risk-assessment-scores-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
}

resource "github_actions_environment_secret" "hmpps-risk-assessment-scores-to-delius-secrets" {
  for_each = {
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_QUEUE_NAME"              = module.hmpps-risk-assessment-scores-to-delius-queue.sqs_name
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_QUEUE_ACCESS_KEY_ID"     = module.hmpps-risk-assessment-scores-to-delius-queue.access_key_id
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_QUEUE_SECRET_ACCESS_KEY" = module.hmpps-risk-assessment-scores-to-delius-queue.secret_access_key
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_DLQ_NAME"                = module.hmpps-risk-assessment-scores-to-delius-dlq.sqs_name
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_DLQ_ACCESS_KEY_ID"       = module.hmpps-risk-assessment-scores-to-delius-dlq.access_key_id
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_DLQ_SECRET_ACCESS_KEY"   = module.hmpps-risk-assessment-scores-to-delius-dlq.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = "preprod"
  secret_name     = each.key
  plaintext_value = each.value
}
