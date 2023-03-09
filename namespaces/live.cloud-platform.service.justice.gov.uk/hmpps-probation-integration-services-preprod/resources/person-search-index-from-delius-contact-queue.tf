resource "aws_sns_topic_subscription" "person-search-index-from-delius-contact-queue-subscription" {
  topic_arn = data.aws_sns_topic.probation-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.person-search-index-from-delius-contact-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["CONTACT_CHANGED"]
  })
}

module "person-search-index-from-delius-contact-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "person-search-index-from-delius"
  sqs_name    = "person-search-index-from-delius-contact-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.person-search-index-from-delius-contact-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-contact-queue-policy" {
  queue_url = module.person-search-index-from-delius-contact-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "person-search-index-from-delius-contact-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application               = "person-search-index-from-delius"
  sqs_name                  = "person-search-index-from-delius-contact-dlq"
  message_retention_seconds = 604800 # 1 week
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-contact-dlq-policy" {
  queue_url = module.person-search-index-from-delius-contact-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "github_actions_environment_secret" "person-search-index-from-delius-contact-queue-name-secret" {
  for_each = {
    "PERSON_SEARCH_INDEX_FROM_DELIUS_CONTACT_SQS_QUEUE_NAME"              = module.person-search-index-from-delius-contact-queue.sqs_name
    "PERSON_SEARCH_INDEX_FROM_DELIUS_CONTACT_SQS_QUEUE_ACCESS_KEY_ID"     = module.person-search-index-from-delius-contact-queue.access_key_id
    "PERSON_SEARCH_INDEX_FROM_DELIUS_CONTACT_SQS_QUEUE_SECRET_ACCESS_KEY" = module.person-search-index-from-delius-contact-queue.secret_access_key
    "PERSON_SEARCH_INDEX_FROM_DELIUS_CONTACT_SQS_DLQ_NAME"                = module.person-search-index-from-delius-contact-dlq.sqs_name
    "PERSON_SEARCH_INDEX_FROM_DELIUS_CONTACT_SQS_DLQ_ACCESS_KEY_ID"       = module.person-search-index-from-delius-contact-dlq.access_key_id
    "PERSON_SEARCH_INDEX_FROM_DELIUS_CONTACT_SQS_DLQ_SECRET_ACCESS_KEY"   = module.person-search-index-from-delius-contact-dlq.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = var.github_environment_name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "kubernetes_secret" "person-search-index-from-delius-contact-queue-secret" {
  metadata {
    name      = "person-search-index-from-delius-contact-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.person-search-index-from-delius-contact-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.person-search-index-from-delius-contact-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.person-search-index-from-delius-contact-queue.secret_access_key
  }
}

resource "kubernetes_secret" "person-search-index-from-delius-contact-dlq-secret" {
  metadata {
    name      = "person-search-index-from-delius-contact-dlq"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.person-search-index-from-delius-contact-dlq.sqs_name
    AWS_ACCESS_KEY_ID     = module.person-search-index-from-delius-contact-dlq.access_key_id
    AWS_SECRET_ACCESS_KEY = module.person-search-index-from-delius-contact-dlq.secret_access_key
  }
}
