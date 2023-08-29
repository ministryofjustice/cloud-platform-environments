module "hmpps_reductions_completed_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "hmpps_reductions_completed_event_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_reductions_completed_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

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

module "hmpps_reductions_completed_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "hmpps_reductions_completed_event_dlq"
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


resource "kubernetes_secret" "hmpps_reductions_completed_event_queue" {
  metadata {
    name      = "hmpps-reductions-completed-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_reductions_completed_queue.access_key_id
    secret_access_key = module.hmpps_reductions_completed_queue.secret_access_key
    sqs_queue_url     = module.hmpps_reductions_completed_queue.sqs_id
    sqs_queue_arn     = module.hmpps_reductions_completed_queue.sqs_arn
    sqs_queue_name    = module.hmpps_reductions_completed_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_reductions_completed_dead_letter_queue" {
  metadata {
    name      = "hmpps-reductions-completed-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_reductions_completed_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_reductions_completed_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_reductions_completed_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_reductions_completed_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_reductions_completed_dead_letter_queue.sqs_name
  }
}
