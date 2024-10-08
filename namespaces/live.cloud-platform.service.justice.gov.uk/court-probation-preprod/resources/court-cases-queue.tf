module "court-cases-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                    = "court-cases"
  encrypt_sqs_kms             = "true"
  message_retention_seconds   = 1209600
  visibility_timeout_seconds  = 120
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.court-cases-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "court-cases-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                    = "court-cases-dlq"
  encrypt_sqs_kms             = "true"
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

########  Secrets

resource "kubernetes_secret" "court-cases-queue-secret" {
  metadata {
    name      = "court-cases-queue-credentials"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.court-cases-queue.sqs_id
    sqs_arn  = module.court-cases-queue.sqs_arn
    sqs_name = module.court-cases-queue.sqs_name
  }
}

resource "kubernetes_secret" "court-cases-dlq-secret" {
  metadata {
    name      = "court-cases-dlq-credentials"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.court-cases-dlq.sqs_id
    sqs_arn  = module.court-cases-dlq.sqs_arn
    sqs_name = module.court-cases-dlq.sqs_name
  }
}
