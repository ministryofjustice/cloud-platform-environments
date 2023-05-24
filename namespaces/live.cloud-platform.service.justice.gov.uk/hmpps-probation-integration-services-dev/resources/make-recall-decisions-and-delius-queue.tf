resource "aws_sns_topic_subscription" "make-recall-decisions-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.make-recall-decisions-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-recall.recommendation.started",
      "prison-recall.recommendation.management-oversight"
    ]
  })
}

module "make-recall-decisions-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "make-recall-decisions-and-delius"
  sqs_name    = "make-recall-decisions-and-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.make-recall-decisions-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "make-recall-decisions-and-delius-queue-policy" {
  queue_url = module.make-recall-decisions-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "make-recall-decisions-and-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "make-recall-decisions-and-delius"
  sqs_name    = "make-recall-decisions-and-delius-dlq"
}

resource "aws_sqs_queue_policy" "make-recall-decisions-and-delius-dlq-policy" {
  queue_url = module.make-recall-decisions-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "make-recall-decisions-and-delius-queue-secret" {
  metadata {
    name      = "make-recall-decisions-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.make-recall-decisions-and-delius-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.make-recall-decisions-and-delius-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.make-recall-decisions-and-delius-queue.secret_access_key
  }
}
