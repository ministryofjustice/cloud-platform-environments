resource "aws_sns_topic_subscription" "risk-assessment-scores-to-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.risk-assessment-scores-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["risk-assessment.scores.determined"]
  })
}

module "risk-assessment-scores-to-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "risk-assessment-scores-to-delius"
  sqs_name    = "risk-assessment-scores-to-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.risk-assessment-scores-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "risk-assessment-scores-to-delius-queue-policy" {
  queue_url = module.risk-assessment-scores-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "risk-assessment-scores-to-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "risk-assessment-scores-to-delius"
  sqs_name    = "risk-assessment-scores-to-delius-dlq"
}

resource "aws_sqs_queue_policy" "risk-assessment-scores-to-delius-dlq-policy" {
  queue_url = module.risk-assessment-scores-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "github_actions_environment_secret" "risk-assessment-scores-to-delius-secrets" {
  for_each = {
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_QUEUE_NAME"              = module.risk-assessment-scores-to-delius-queue.sqs_name
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_QUEUE_ACCESS_KEY_ID"     = module.risk-assessment-scores-to-delius-queue.access_key_id
    "RISK_ASSESSMENT_SCORES_TO_DELIUS_SQS_QUEUE_SECRET_ACCESS_KEY" = module.risk-assessment-scores-to-delius-queue.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = var.github_environment_name
  secret_name     = each.key
  plaintext_value = each.value
}
