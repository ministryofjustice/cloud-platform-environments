### nomis merge events subscription

resource "aws_sns_topic_subscription" "cpr_nomis_merge_domain_events_subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.cpr_nomis_merge_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.merged"
    ]
  })
}

module "cpr_nomis_merge_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  # Queue configuration
  sqs_name                   = "cpr_nomis_merge_events_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cpr_nomis_merge_events_dead_letter_queue.sqs_arn
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

### Dead letter queue
module "cpr_nomis_merge_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  # Queue configuration
  sqs_name        = "cpr_nomis_merge_events_dlq"
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

########  Secrets

resource "kubernetes_secret" "cpr_nomis_merge_events_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-nomis-merge-events-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_nomis_merge_events_queue.sqs_id
    sqs_queue_arn  = module.cpr_nomis_merge_events_queue.sqs_arn
    sqs_queue_name = module.cpr_nomis_merge_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "cpr_nomis_merge_events_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-nomis-merge-events-dlq-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_nomis_merge_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.cpr_nomis_merge_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.cpr_nomis_merge_events_dead_letter_queue.sqs_name
  }
}
