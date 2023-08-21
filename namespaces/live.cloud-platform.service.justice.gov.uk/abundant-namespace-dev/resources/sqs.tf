module "abundant_namespace_sqs" {
  # remember to check the latest version
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=main"

  # Queue configuration
  sqs_name        = "abundant_namespace_sqs"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "abundant_namespace_sqs" {
  metadata {
    name      = "sqs"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.abundant_namespace_sqs.sqs_id
    sqs_arn  = module.abundant_namespace_sqs.sqs_arn
    sqs_name = module.abundant_namespace_sqs.sqs_name
  }
}
