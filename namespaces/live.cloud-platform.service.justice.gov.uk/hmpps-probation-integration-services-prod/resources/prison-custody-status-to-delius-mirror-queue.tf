resource "aws_sns_topic_subscription" "prison-custody-status-to-delius-mirror-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.prison-custody-status-to-delius-mirror-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.received",
    ]
  })
}

module "prison-custody-status-to-delius-mirror-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "prison-custody-status-to-delius-mirror"
  sqs_name    = "prison-custody-status-to-delius-mirror-queue"
}

resource "aws_sqs_queue_policy" "prison-custody-status-to-delius-mirror-queue-policy" {
  queue_url = module.prison-custody-status-to-delius-mirror-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}
