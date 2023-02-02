resource "aws_sns_topic_subscription" "gdx-data-share-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.gdx-data-share-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.received",
    ]
  })
}

module "gdx-data-share-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "gdx-data-share"
  sqs_name    = "gdx-data-share-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.gdx-data-share-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "gdx-data-share-queue-policy" {
  queue_url = module.gdx-data-share-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "gdx-data-share-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "gdx-data-share"
  sqs_name    = "gdx-data-share-dlq"
}

resource "aws_sqs_queue_policy" "gdx-data-share-dlq-policy" {
  queue_url = module.gdx-data-share-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

