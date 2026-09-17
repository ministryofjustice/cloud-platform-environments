module "returns_events_fifo_queue" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"
  sqs_name                    = "returns_events_queue"
  encrypt_sqs_kms             = "true"
  message_retention_seconds   = 1209600
  visibility_timeout_seconds  = 120
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.returns_events_fifo_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
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

resource "kubernetes_secret" "returns_events_fifo_queue" {
  metadata {
    name      = "sqs-returns-events-fifo-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.returns_events_fifo_queue.sqs_id
    sqs_queue_arn  = module.returns_events_fifo_queue.sqs_arn
    sqs_queue_name = module.returns_events_fifo_queue.sqs_name
  }
}


######## Dead letter queue

module "returns_events_fifo_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                    = "returns_events_dlq"
  encrypt_sqs_kms             = "true"
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  # Tags
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

resource "kubernetes_secret" "returns_events_fifo_dead_letter_queue" {
  metadata {
    name      = "sqs-returns-events-fifo-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.returns_events_fifo_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.returns_events_fifo_dead_letter_queue.sqs_arn
    sqs_queue_name = module.returns_events_fifo_dead_letter_queue.sqs_name
  }
}
