module "pkdev_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.2"

  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
  encrypt_sqs_kms        = "false"

  providers = {
    aws = aws.london
  }
}


resource "kubernetes_secret" "cp_test_queue" {
  metadata {
    name      = "pkdev-queue-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.pkdev_queue.access_key_id
    secret_access_key = module.pkdev_queue.secret_access_key
    sqs_id            = module.pkdev_queue.sqs_id
    sqs_arn           = module.pkdev_queue.sqs_arn
    sqs_name          = module.pkdev_queue.sqs_name
  }
}
