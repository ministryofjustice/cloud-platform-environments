resource "aws_sns_topic_subscription" "refer-and-monitor-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.refer-and-monitor-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "intervention.session-appointment.session-feedback-submitted",
      "intervention.session-appointment.missed",
      "intervention.session-appointment.attended",
      "intervention.referral.sent",
      "intervention.referral.prematurely-ended",
      "intervention.referral.completed",
      "intervention.referral.cancelled",
      "intervention.initial-assessment-appointment.session-feedback-submitted",
      "intervention.initial-assessment-appointment.missed",
      "intervention.initial-assessment-appointment.attended"
    ]
  })
}

module "refer-and-monitor-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "refer-and-monitor-and-delius"
  sqs_name    = "refer-and-monitor-and-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.refer-and-monitor-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "refer-and-monitor-and-delius-queue-policy" {
  queue_url = module.refer-and-monitor-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "refer-and-monitor-and-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "refer-and-monitor-and-delius"
  sqs_name    = "refer-and-monitor-and-delius-dlq"
}

resource "aws_sqs_queue_policy" "refer-and-monitor-and-delius-dlq-policy" {
  queue_url = module.refer-and-monitor-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "github_actions_environment_secret" "refer-and-monitor-and-delius-secrets" {
  for_each = {
    "REFER_AND_MONITOR_AND_DELIUS_SQS_QUEUE_NAME"              = module.refer-and-monitor-and-delius-queue.sqs_name
    "REFER_AND_MONITOR_AND_DELIUS_SQS_QUEUE_ACCESS_KEY_ID"     = module.refer-and-monitor-and-delius-queue.access_key_id
    "REFER_AND_MONITOR_AND_DELIUS_SQS_QUEUE_SECRET_ACCESS_KEY" = module.refer-and-monitor-and-delius-queue.secret_access_key
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = var.github_environment_name
  secret_name     = each.key
  plaintext_value = each.value
}
