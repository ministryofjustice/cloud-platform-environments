resource "aws_sns_topic_subscription" "risk-assessment-scores-to-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.risk-assessment-scores-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["risk-assessment.scores.determined"]
  })
}

module "risk-assessment-scores-to-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
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

resource "kubernetes_secret" "risk-assessment-scores-to-delius-queue-secret" {
  metadata {
    name      = "risk-assessment-scores-to-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.risk-assessment-scores-to-delius-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.risk-assessment-scores-to-delius-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.risk-assessment-scores-to-delius-queue.secret_access_key
  }
}
