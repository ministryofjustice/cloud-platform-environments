resource "aws_sns_topic_subscription" "workforce-allocations-to-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.workforce-allocations-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "person.community.manager.allocated",
      "event.manager.allocated",
      "requirement.manager.allocated",
    ]
  })
}

module "workforce-allocations-to-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "workforce-allocations-to-delius"
  sqs_name    = "workforce-allocations-to-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.workforce-allocations-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "workforce-allocations-to-delius-queue-policy" {
  queue_url = module.workforce-allocations-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "workforce-allocations-to-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "workforce-allocations-to-delius"
  sqs_name    = "workforce-allocations-to-delius-dlq"
}

resource "aws_sqs_queue_policy" "workforce-allocations-to-delius-dlq-policy" {
  queue_url = module.workforce-allocations-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "workforce-allocations-to-delius-queue-secret" {
  metadata {
    name      = "workforce-allocations-to-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.workforce-allocations-to-delius-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.workforce-allocations-to-delius-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.workforce-allocations-to-delius-queue.secret_access_key
  }
}
