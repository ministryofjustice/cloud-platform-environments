module "hmcts-data-ingestion-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name = "hmcts-data-ingestion-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmcts-data-ingestion-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "hmcts-data-ingestion"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "hmcts-data-ingestion-queue-queue-policy" {
  queue_url = module.hmcts-data-ingestion-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "hmcts-data-ingestion-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmcts-data-ingestion-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "hmcts-data-ingestion"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "hmcts-data-ingestion-dlq-policy" {
  queue_url = module.hmcts-data-ingestion-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "hmcts-data-ingestion-queue-secret" {
  metadata {
    name      = "hmcts-data-ingestion-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.hmcts-data-ingestion-queue.sqs_name
  }
}
