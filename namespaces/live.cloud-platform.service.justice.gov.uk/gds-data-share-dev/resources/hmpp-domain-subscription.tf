resource "aws_sns_topic_subscription" "gdx-data-share-queue-subscription" {
  provider  = aws.london
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.gdx_data_share_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.received",
    ]
  })
}

module "gdx_data_share_queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "gdx-data-share"
  sqs_name    = "gdx-data-share-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.gdx_data_share_dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

module "gdx_data_share_dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "gdx-data-share"
  sqs_name    = "gdx-data-share-dlq"
}

