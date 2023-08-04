resource "aws_sns_topic_subscription" "person-search-index-from-delius-person-queue-subscription" {
  topic_arn = data.aws_sns_topic.probation-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.person-search-index-from-delius-person-queue.sqs_arn
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

module "person-search-index-from-delius-person-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "person-search-index-from-delius"
  sqs_name    = "person-search-index-from-delius-person-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.person-search-index-from-delius-person-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-person-queue-policy" {
  queue_url = module.person-search-index-from-delius-person-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "person-search-index-from-delius-person-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application               = "person-search-index-from-delius"
  sqs_name                  = "person-search-index-from-delius-person-dlq"
  message_retention_seconds = 86400 # 1 day
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-person-dlq-policy" {
  queue_url = module.person-search-index-from-delius-person-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "person-search-index-from-delius-person-queue-secret" {
  metadata {
    name      = "person-search-index-from-delius-person-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.person-search-index-from-delius-person-queue.sqs_name
  }
}

resource "kubernetes_secret" "person-search-index-from-delius-person-dlq-secret" {
  metadata {
    name      = "person-search-index-from-delius-person-dlq"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.person-search-index-from-delius-person-dlq.sqs_name
  }
}
