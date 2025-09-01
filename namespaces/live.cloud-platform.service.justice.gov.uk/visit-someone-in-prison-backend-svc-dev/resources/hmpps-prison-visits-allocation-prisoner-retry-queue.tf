######## Prison visits allocation prisoner retry queue.
  
######## This will allow the visit-allocation-api to retry and failed allocations to individual prisoners when running the prison processing job.
######## Without it, we would need to wait until the next job to trigger (next day) or reprocess the whole prison.

module "hmpps_prison_visits_allocation_prisoner_retry_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_allocation_prisoner_retry_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 10800 #3 hours
  visibility_timeout_seconds = 600   #10 mins

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "book-a-prison-visit" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_arn
    maxReceiveCount     = 1
  })

  providers = {
    aws = aws.london
  }
}

######## Dead letter queue

module "hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_allocation_prisoner_retry_dlq"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 36000 # 10 hours
  visibility_timeout_seconds = 600   # 10 minutes

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "book-a-prison-visit" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

########  Secrets
resource "kubernetes_secret" "hmpps_prison_visits_allocation_prisoner_retry_queue" {
  ## For metadata use - not _
  metadata {
    name      = "sqs-prison-visits-allocation-prisoner-retry-queue-secret"
    namespace = "visit-someone-in-prison-backend-svc-dev"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_allocation_prisoner_retry_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_allocation_prisoner_retry_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_allocation_prisoner_retry_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-allocation-prisoner-retry-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-dev"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_name
  }
}
