resource "aws_sns_topic_subscription" "hmpps-prison-custody-status-to-delius-queue-subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps-prison-custody-status-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.received",
    ]
  })
}

module "hmpps-prison-custody-status-to-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "prison-custody-status-to-delius"
  sqs_name               = "prison-custody-status-to-delius-queue"

  message_retention_seconds = 14 * 86400 # 2 weeks
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps-prison-custody-status-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "hmpps-prison-custody-status-to-delius-queue-policy" {
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
    resources = [module.hmpps-prison-custody-status-to-delius-queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "hmpps-prison-custody-status-to-delius-queue-policy" {
  queue_url = module.hmpps-prison-custody-status-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps-prison-custody-status-to-delius-queue-policy.json
}

module "hmpps-prison-custody-status-to-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "prison-custody-status-to-delius"
  sqs_name               = "prison-custody-status-to-delius-dlq"

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps-prison-custody-status-to-delius-dlq-policy" {
  queue_url = module.hmpps-prison-custody-status-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
}

resource "github_actions_environment_secret" "hmpps-prison-custody-status-to-delius-queue-name-secret" {
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = "prod"
  secret_name     = "PRISON_CUSTODY_STATUS_TO_DELIUS_QUEUE_NAME"
  plaintext_value = module.hmpps-prison-custody-status-to-delius-queue.sqs_name
}
