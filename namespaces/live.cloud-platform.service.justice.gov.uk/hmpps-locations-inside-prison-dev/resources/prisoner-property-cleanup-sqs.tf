# Work queue (+ DLQ) for hmpps-prisoner-property-api's legacy property clean-up job.
# The API sends a single "start" message to this queue itself after it has committed a
# clean-up job, and its LegacyCleanupListener consumes it - there is no SNS topic
# subscription. Modelled on prisoner-property-sqs.tf in this folder; the queue policy is
# not needed because only the app's own IRSA role (prisoner-property-irsa.tf) sends to it.

module "prisoner_property_cleanup_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                   = "prisoner-property-cleanup-queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours - a job that has not run within that is stale
  visibility_timeout_seconds = 1800  # 30 minutes - a large prison takes minutes to process; must exceed that so the message is not redelivered mid-run

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_property_cleanup_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "prisoner_property_cleanup_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "prisoner-property-cleanup-dlq"
  encrypt_sqs_kms = "true"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_property_cleanup_queue" {
  metadata {
    name      = "sqs-prisoner-property-cleanup-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_property_cleanup_queue.sqs_id
    sqs_queue_arn  = module.prisoner_property_cleanup_queue.sqs_arn
    sqs_queue_name = module.prisoner_property_cleanup_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_property_cleanup_dlq" {
  metadata {
    name      = "sqs-prisoner-property-cleanup-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_property_cleanup_dlq.sqs_id
    sqs_queue_arn  = module.prisoner_property_cleanup_dlq.sqs_arn
    sqs_queue_name = module.prisoner_property_cleanup_dlq.sqs_name
  }
}
