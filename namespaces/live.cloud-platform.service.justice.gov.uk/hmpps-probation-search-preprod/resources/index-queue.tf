module "probation-search-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment
  namespace              = var.namespace
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  application            = var.application
  sqs_name               = "probation-search-queue"

  message_retention_seconds = 14 * 86400 # 2 weeks
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.probation-search-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "probation-search-queue-policy" {
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
#    condition {
#      variable = "aws:SourceArn"
#      test     = "ArnEquals"
#      values   = [module.hmpps-domain-events.topic_arn]
#    }
    resources = [module.probation-search-queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "probation-search-queue-policy" {
  queue_url = module.probation-search-queue.sqs_id
  policy    = data.aws_iam_policy_document.probation-search-queue-policy.json
}

module "probation-search-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment
  namespace              = var.namespace
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  application            = var.application
  sqs_name               = "probation-search-dlq"

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "probation-search-dlq-policy" {
  queue_url = module.probation-search-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
}

resource "github_actions_environment_secret" "probation-search-queue-name-secret" {
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = "preprod"
  secret_name     = "PERSON_SEARCH_INDEX_FROM_DELIUS_QUEUE_NAME"
  plaintext_value = module.probation-search-queue.sqs_name
}
