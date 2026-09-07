module "pcms_communication_insights_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_pcms_communication_insights_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.pcms_communication_insights_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = replace(var.team_name, " ", "-") # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "pcms_communication_insights_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_pcms_communication_insights_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = replace(var.team_name, " ", "-") # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pcms_communication_insights_queue_secret" {
  metadata {
    name      = "sqs-pcms-communication-insights-job-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pcms_communication_insights_queue.sqs_id
    sqs_queue_arn  = module.pcms_communication_insights_queue.sqs_arn
    sqs_queue_name = module.pcms_communication_insights_queue.sqs_name
  }
}

resource "kubernetes_secret" "pcms_communication_insights_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-pcms-communication-insights-job-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pcms_communication_insights_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.pcms_communication_insights_dead_letter_queue.sqs_arn
    sqs_queue_name = module.pcms_communication_insights_dead_letter_queue.sqs_name
  }
}
