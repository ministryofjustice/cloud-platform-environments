module "hmpps_activities_management_jobs_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_activities_management_jobs_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 #12 hours
  visibility_timeout_seconds = 600   #10 mins

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_activities_management_jobs_dlq.sqs_arn
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

module "hmpps_activities_management_jobs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_activities_management_jobs_dlq"
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

resource "kubernetes_secret" "hmpps_activities_management_jobs_queue" {
  ## For metadata use - not
  metadata {
    name = "sqs-activities-management-jobs-queue-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_activities_management_jobs_queue.sqs_id
    sqs_queue_arn  = module.hmpps_activities_management_jobs_queue.sqs_arn
    sqs_queue_name = module.hmpps_activities_management_jobs_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_activities_management_job_letter_queue" {
  metadata {
    name = "sqs-activities-management-jobs-dlq-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_activities_management_jobs_dlq.sqs_id
    sqs_queue_arn  = module.hmpps_activities_management_jobs_dlq.sqs_arn
    sqs_queue_name = module.hmpps_activities_management_jobs_dlq.sqs_name
  }
}

