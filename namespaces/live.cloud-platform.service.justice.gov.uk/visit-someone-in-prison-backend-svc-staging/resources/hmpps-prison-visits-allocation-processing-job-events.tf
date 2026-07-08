######################################## Prison visits allocation events for visit someone in prison
######## This will allow the visit-allocation-api to monitor for visit allocation jobs to run on a prison basis
######## Main queue

module "hmpps_prison_visits_allocation_processing_job_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_allocation_processing_job_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 #12 hours
  visibility_timeout_seconds = 600   #10 mins

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prison_visits_allocation_processing_job_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
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
module "hmpps_prison_visits_allocation_processing_job_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prison_visits_allocation_processing_job_dlq"
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
resource "kubernetes_secret" "hmpps_prison_visits_allocation_processing_job_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-allocation-processing-job-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-staging"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_allocation_processing_job_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_allocation_processing_job_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_allocation_processing_job_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_allocation_processing_job_dead_letter_queue" {
  metadata {
    name = "sqs-hmpps-prison-visits-allocation-processing-job-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-staging"
  }

  data = {
    sqs_queue_url  = module.hmpps_prison_visits_allocation_processing_job_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prison_visits_allocation_processing_job_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prison_visits_allocation_processing_job_dead_letter_queue.sqs_name
  }
}
