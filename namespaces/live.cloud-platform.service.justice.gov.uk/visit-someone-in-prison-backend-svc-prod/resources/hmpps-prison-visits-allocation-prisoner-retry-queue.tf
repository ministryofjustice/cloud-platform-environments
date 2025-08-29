######## Prison visits allocation prisoner retry queue.
######## This will allow the visit-allocation-api to retry and failed allocations to individual prisoners when running the prison processing job.
######## Without it, we would need to wait until the next job to trigger (next day) or reprocess the whole prison.

module "hmpps_prison_visits_allocation_prisoner_retry_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_allocation_prisoner_retry_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 #12 hours
  visibility_timeout_seconds = 1200  #20 mins (we want to delay retry, to avoid intermittent API issues)

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_arn
    maxReceiveCount     = 36 # We want to have it retry every 20 minutes, for 12 hours so we can manually fix in the morning if required before DLQ'ing the message.
  })

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

######## Dead letter queue

module "hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prison_visits_allocation_prisoner_retry_dlq"
  encrypt_sqs_kms = "true"

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
    namespace = "visit-someone-in-prison-backend-svc-prod"
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
    namespace = "visit-someone-in-prison-backend-svc-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.sqs_name
  }
}
