resource "aws_sns_topic_subscription" "hmpps-person-search-index-from-delius-queue-subscription" {
  provider  = aws.london
  topic_arn = module.probation_offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps-person-search-index-from-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_CHANGED",
      "OFFENDER_MANAGER_CHANGED",
      "OFFENDER_REGISTRATION_CHANGED",
      "OFFENDER_REGISTRATION_DEREGISTERED",
      "OFFENDER_REGISTRATION_DELETED",
      "SENTENCE_CHANGED",
      "CONVICTION_CHANGED"
    ]
  })
}

module "hmpps-person-search-index-from-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "person-search-index-from-delius"
  sqs_name               = "person-search-index-from-delius-queue"

  message_retention_seconds = 14 * 86400 # 2 weeks
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps-person-search-index-from-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "hmpps-person-search-index-from-delius-queue-policy" {
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
      values   = [module.probation_offender_events.topic_arn]
    }
    resources = [module.hmpps-person-search-index-from-delius-queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "hmpps-person-search-index-from-delius-queue-policy" {
  queue_url = module.hmpps-person-search-index-from-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps-person-search-index-from-delius-queue-policy.json
}

module "hmpps-person-search-index-from-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = "hmpps-probation-integration"
  application            = "person-search-index-from-delius"
  sqs_name               = "person-search-index-from-delius-dlq"

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps-person-search-index-from-delius-dlq-policy" {
  queue_url = module.hmpps-person-search-index-from-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
}

resource "github_actions_environment_secret" "hmpps-person-search-index-from-delius-queue-name-secret" {
  for_each = {
    "PERSON_SEARCH_INDEX_FROM_DELIUS_SQS_QUEUE_NAME"              = module.hmpps-person-search-index-from-delius-queue.sqs_name
    "PERSON_SEARCH_INDEX_FROM_DELIUS_SQS_QUEUE_ACCESS_KEY_ID"     = module.hmpps-person-search-index-from-delius-queue.access_key_id
    "PERSON_SEARCH_INDEX_FROM_DELIUS_SQS_QUEUE_SECRET_ACCESS_KEY" = module.hmpps-person-search-index-from-delius-queue.secret_access_key
    "PERSON_SEARCH_INDEX_FROM_DELIUS_SQS_DLQ_NAME"                = module.hmpps-person-search-index-from-delius-dlq.sqs_name
    "PERSON_SEARCH_INDEX_FROM_DELIUS_SQS_DLQ_ACCESS_KEY_ID"       = module.hmpps-person-search-index-from-delius-dlq.access_key_id
    "PERSON_SEARCH_INDEX_FROM_DELIUS_SQS_DLQ_SECRET_ACCESS_KEY"   = module.hmpps-person-search-index-from-delius-dlq.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = "preprod"
  secret_name     = each.key
  plaintext_value = each.value
}
