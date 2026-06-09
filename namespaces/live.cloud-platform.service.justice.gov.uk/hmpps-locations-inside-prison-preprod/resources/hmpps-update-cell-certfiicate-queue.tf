module "update_cell_certificate_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "update_cell_certificate_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours
  visibility_timeout_seconds = 120   # 2 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.update_cell_certificate_dlq.sqs_arn
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

  providers = {
    aws = aws.london
  }
}

# Dead letter queue

module "update_cell_certificate_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "update_cell_certificate_dlq"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 604800 # 7 days
  visibility_timeout_seconds = 120    # 2 minutes

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

# Secrets

resource "kubernetes_secret" "update_cell_certificate_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-update-update-cell-certificate-queue-secret"
    ## Name space where the listening service is found
    namespace = "hmpps-locations-inside-prison-preprod"
  }

  data = {
    sqs_queue_url  = module.update_cell_certificate_queue.sqs_id
    sqs_queue_arn  = module.update_cell_certificate_queue.sqs_arn
    sqs_queue_name = module.update_cell_certificate_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_update_cell_certificate_dlq" {
  ## For metadata use - not _
  metadata {
    name = "sqs-update-cell-certificate-dlq-secret"
    ## Name space where the listening service is found
    namespace = "hmpps-locations-inside-prison-preprod"
  }

  data = {
    sqs_queue_url  = module.update_cell_certificate_dlq.sqs_id
    sqs_queue_arn  = module.update_cell_certificate_dlq.sqs_arn
    sqs_queue_name = module.update_cell_certificate_dlq.sqs_name
  }
}
