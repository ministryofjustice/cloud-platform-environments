module "laa_govuk_notify_orchestrator_development_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  # This queue is actually named laa_govuk_notify_orchestrator_development_queue.fifo,
  # however, .fifo is appended later
  sqs_name        = "laa_govuk_notify_orchestrator_development_queue"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Queue Parameters
  fifo_queue                  = "true"
  content_based_deduplication = "false"
  receive_wait_time_seconds   = 10
  visibility_timeout_seconds  = 7320 # 2 Hours + 120 seconds to allow for worse case network/ execution time.

  providers = {
    aws = aws.london
  }

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.laa_govuk_notify_orchestrator_development_dlq.sqs_arn}","maxReceiveCount": 5
  }
  EOF
}

resource "kubernetes_secret" "sqs" {
  metadata {
    name      = "sqs"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.laa_govuk_notify_orchestrator_development_sqs.sqs_id
    sqs_arn  = module.laa_govuk_notify_orchestrator_development_sqs.sqs_arn
    sqs_name = module.laa_govuk_notify_orchestrator_development_sqs.sqs_name
  }
}

module "laa_govuk_notify_orchestrator_development_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "laa_govuk_notify_orchestrator_development_dlq"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Queue Parameters
  fifo_queue = "true"

  providers = {
    aws = aws.london
  }
}