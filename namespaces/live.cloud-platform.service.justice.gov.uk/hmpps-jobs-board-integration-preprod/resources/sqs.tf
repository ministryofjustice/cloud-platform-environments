module "hmpps_jobs_board_integration_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  # Queue configuration
  sqs_name                  = "hmpps_jobs_board_integration_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "hmpps_jobs_board_integration_queue" {
  metadata {
    name      = "sqs-intergration-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_jobs_board_integration_queue.sqs_id
    sqs_queue_arn  = module.hmpps_jobs_board_integration_queue.sqs_arn
    sqs_queue_name = module.hmpps_jobs_board_integration_queue.sqs_name
  }
}
