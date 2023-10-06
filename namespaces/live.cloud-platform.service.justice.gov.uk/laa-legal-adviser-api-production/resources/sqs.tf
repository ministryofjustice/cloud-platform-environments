module "laalaa_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "laalaa_production_queue"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.email

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "sqs" {
  metadata {
    name      = "sqs"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.laalaa_sqs.sqs_id
    sqs_arn  = module.laalaa_sqs.sqs_arn
    sqs_name = module.laalaa_sqs.sqs_name
  }
}
