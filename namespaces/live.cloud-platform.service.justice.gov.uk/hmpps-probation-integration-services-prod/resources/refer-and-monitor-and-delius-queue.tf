resource "aws_sns_topic_subscription" "refer-and-monitor-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.refer-and-monitor-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "intervention.referral.ended",
      "intervention.session-appointment.session-feedback-submitted",
      "intervention.initial-assessment-appointment.session-feedback-submitted",
      "intervention.action-plan.submitted",
      "intervention.action-plan.approved"
    ]
  })
}

module "refer-and-monitor-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
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

resource "kubernetes_secret" "refer-and-monitor-and-delius-queue-secret" {
  metadata {
    name      = "refer-and-monitor-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.refer-and-monitor-and-delius-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.refer-and-monitor-and-delius-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.refer-and-monitor-and-delius-queue.secret_access_key
  }
}
