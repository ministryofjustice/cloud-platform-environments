# Prison visits write events for visit someone in prison
  

module "eawp_assessment_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "eawp_assessment_events_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours
  visibility_timeout_seconds = 120   # 2 minutess

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.eawp_assessment_events_dead_letter_queue.sqs_arn
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
}

# Dead letter queue

module "eawp_assessment_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "eawp_assessment_events_dlq"
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
}

# Secrets

resource "kubernetes_secret" "education-and-work-plan-assessments-queue" {
  ## For metadata use - not _
  metadata {
    name = "education-and-work-plan-assessments-queue"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.eawp_assessment_events_queue.sqs_id
    sqs_queue_arn  = module.eawp_assessment_events_queue.sqs_arn
    sqs_queue_name = module.eawp_assessment_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "education-and-work-plan-assessments-dlq" {
  ## For metadata use - not _
  metadata {
    name = "education-and-work-plan-assessments-dlq"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.eawp_assessment_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.eawp_assessment_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.eawp_assessment_events_dead_letter_queue.sqs_name
  }
}
