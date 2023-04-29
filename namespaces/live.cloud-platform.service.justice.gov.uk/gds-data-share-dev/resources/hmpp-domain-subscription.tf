resource "aws_sns_topic_subscription" "gds-data-share-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.gds_data_share_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.received",
    ]
  })
}

module "gds_data_share_queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "gds-data-share"
  sqs_name    = "gds-data-share-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.gds_data_share_dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

module "gds_data_share_dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "gds-data-share"
  sqs_name    = "gds-data-share-dlq"
}

resource "kubernetes_secret" "gds_data_share_queue" {
  metadata {
    name      = "sqs-gds-data-share-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.gds_data_share_queue.sqs_id
    sqs_queue_arn  = module.gds_data_share_queue.sqs_arn
    sqs_queue_name = module.gds_data_share_queue.sqs_name
  }
}

resource "kubernetes_secret" "gds_data_share_dlq" {
  metadata {
    name      = "sqs-gds-data-share-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.gds_data_share_dlq.sqs_id
    sqs_queue_arn  = module.gds_data_share_dlq.sqs_arn
    sqs_queue_name = module.gds_data_share_dlq.sqs_name
  }
}