resource "aws_sns_topic_subscription" "unpaid-work-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.unpaid-work-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["unpaid-work.assessment.completed"]
  })
}

module "unpaid-work-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "unpaid-work-and-delius"
  sqs_name    = "unpaid-work-and-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.unpaid-work-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "unpaid-work-and-delius-queue-policy" {
  queue_url = module.unpaid-work-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "unpaid-work-and-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "unpaid-work-and-delius"
  sqs_name    = "unpaid-work-and-delius-dlq"
}

resource "aws_sqs_queue_policy" "unpaid-work-and-delius-dlq-policy" {
  queue_url = module.unpaid-work-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "github_actions_environment_secret" "unpaid-work-and-delius-secrets" {
  for_each = {
    "UNPAID_WORK_AND_DELIUS_SQS_QUEUE_NAME"              = module.unpaid-work-and-delius-queue.sqs_name
    "UNPAID_WORK_AND_DELIUS_SQS_QUEUE_ACCESS_KEY_ID"     = module.unpaid-work-and-delius-queue.access_key_id
    "UNPAID_WORK_AND_DELIUS_SQS_QUEUE_SECRET_ACCESS_KEY" = module.unpaid-work-and-delius-queue.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = var.github_environment_name
  secret_name     = each.key
  plaintext_value = each.value
}
