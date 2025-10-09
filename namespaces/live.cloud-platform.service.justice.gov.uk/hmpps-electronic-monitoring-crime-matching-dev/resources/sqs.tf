module "crime_batch_sqs" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "crime_batch_sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.crime_batch_sqs_dlq.sqs_arn
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
}

module "crime_batch_sqs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "crime_batch_sqs_dlq"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "crime_batch_sqs" {
  metadata {
    name      = "sqs-crime-batch-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.crime_batch_sqs.sqs_id
    sqs_queue_arn  = module.crime_batch_sqs.sqs_arn
    sqs_queue_name = module.crime_batch_sqs.sqs_name
  }
}

resource "kubernetes_secret" "crime_batch_sqs_dlq" {
  metadata {
    name      = "sqs-crime-batch-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.crime_batch_sqs_dlq.sqs_id
    sqs_queue_arn  = module.crime_batch_sqs_dlq.sqs_arn
    sqs_queue_name = module.crime_batch_sqs_dlq.sqs_name
  }
}