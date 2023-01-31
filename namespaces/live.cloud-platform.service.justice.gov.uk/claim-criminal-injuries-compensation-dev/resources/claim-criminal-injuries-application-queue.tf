module "claim-criminal-injuries-application-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"

  sqs_name = "claim-criminal-injuries-application-queue"
  fifo_queue             = false
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "claim-criminal-injuries-application-sqs" {
  metadata {
    name      = "application-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id = module.claim-criminal-injuries-application-queue.access_key_id
    secret_access_key = module.claim-criminal-injuries-application-queue.secret_access_key
    sqs_id = module.claim-criminal-injuries-application-queue.sqs_id
    sqs_arn = module.claim-criminal-injuries-application-queue.sqs_arn
    sqs_name = module.claim-criminal-injuries-application-queue.sqs_name
  }
}