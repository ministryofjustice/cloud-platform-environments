module "steve_test_sqs_two" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=sqs-team-change"

  # Queue configuration
  sqs_name        = "sw-cp-testing-sqs-two"
  encrypt_sqs_kms = "false"

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

resource "kubernetes_secret" "steve_test_sqs_two" {
  metadata {
    name      = "sqs-two"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.steve_test_sqs_two.sqs_id
    sqs_arn  = module.steve_test_sqs_two.sqs_arn
    sqs_name = module.steve_test_sqs_two.sqs_name
  }
}
