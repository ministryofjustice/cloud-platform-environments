module "hmpps_alerts_publish_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "hmpps_alerts_publish_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_alerts_publish_dlq.sqs_arn
    maxReceiveCount     = 6
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "hmpps_alerts_publish_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "hmpps_alerts_publish_queue_dl"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_alerts_publish_queue" {
  metadata {
    name      = "hmpps-alerts-publish-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_alerts_publish_queue.sqs_id
    sqs_queue_arn  = module.hmpps_alerts_publish_queue.sqs_arn
    sqs_queue_name = module.hmpps_alerts_publish_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_alerts_publish_dlq" {
  metadata {
    name      = "hmpps-alerts-publish-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_alerts_publish_dlq.sqs_id
    sqs_queue_arn  = module.hmpps_alerts_publish_dlq.sqs_arn
    sqs_queue_name = module.hmpps_alerts_publish_dlq.sqs_name
  }
}
