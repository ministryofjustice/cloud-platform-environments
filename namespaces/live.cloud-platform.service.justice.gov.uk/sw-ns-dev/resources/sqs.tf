module "sqs" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "sw-ns-dev-queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 120

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "sw_ns_dev_queue" {
  metadata {
    name      = "sw-ns-dev-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.sqs.sqs_id
    sqs_arn  = module.sqs.sqs_arn
    sqs_name = module.sqs.sqs_name
  }
}
