module "bulk_comparison_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "bulk_comparison_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.bulk_comparison_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "bulk_comparison_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "bulk_comparison_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "bulk_comparison_queue" {
  metadata {
    name      = "sqs-bulk-comparison-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.bulk_comparison_queue.sqs_id
    sqs_arn  = module.bulk_comparison_queue.sqs_arn
    sqs_name = module.bulk_comparison_queue.sqs_name
  }
}

resource "kubernetes_secret" "bulk_comparison_dead_letter_queue" {
  metadata {
    name      = "sqs-bulk-comparison-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.bulk_comparison_dead_letter_queue.sqs_id
    sqs_arn  = module.bulk_comparison_dead_letter_queue.sqs_arn
    sqs_name = module.bulk_comparison_dead_letter_queue.sqs_name
  }
}
