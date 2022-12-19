data "aws_sns_topic" "hmpps-domain-events-prod" {
  name = "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08"
}

resource "aws_sns_topic_subscription" "prison-custody-status-to-delius-mirror-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events-prod.arn
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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"
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

resource "kubernetes_secret" "prison-custody-status-to-delius-mirror-secrets" {
  metadata {
    name      = "prison-custody-status-to-delius-mirror-queue"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prison-custody-status-to-delius-mirror-queue.access_key_id
    secret_access_key = module.prison-custody-status-to-delius-mirror-queue.secret_access_key
    sqs_queue_url     = module.prison-custody-status-to-delius-mirror-queue.sqs_id
    sqs_queue_arn     = module.prison-custody-status-to-delius-mirror-queue.sqs_arn
    sqs_queue_name    = module.prison-custody-status-to-delius-mirror-queue.sqs_name
  }
}
