module "hmpps_prisoner_search_index_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_prisoner_search_index_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_search_index_dead_letter_queue.sqs_arn
    maxReceiveCount     = 4
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

module "hmpps_prisoner_search_index_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prisoner_search_index_queue_dl"
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

resource "kubernetes_secret" "hmpps_prisoner_search_index_queue" {
  metadata {
    name      = "prisoner-search-indexer-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_search_index_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_search_index_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_search_index_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_search_index_dead_letter_queue" {
  metadata {
    name      = "prisoner-search-indexer-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_search_index_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_search_index_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_search_index_dead_letter_queue.sqs_name
  }
}
