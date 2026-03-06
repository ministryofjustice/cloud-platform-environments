module "hmpps_prisoner_pay_api_jobs_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "jobs_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 #12 hours
  visibility_timeout_seconds = 600   #10 mins

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_pay_api_jobs_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-prisoner-pay" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "hmpps_prisoner_pay_api_jobs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "jobs_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-prisoner-pay" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prisoner_pay_api_jobs_queue" {
  ## For metadata use - not
  metadata {
    name = "sqs-prisoner-pay-api-jobs-queue-secret"
    ## Namespace where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_pay_api_jobs_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_pay_api_jobs_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_pay_api_jobs_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_pay_api_jobs_dlq" {
  metadata {
    name = "sqs-prisoner-pay-api-jobs-dlq-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_pay_api_jobs_dlq.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_pay_api_jobs_dlq.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_pay_api_jobs_dlq.sqs_name
  }
}
