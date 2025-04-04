module "steve_test_sqs_four" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=sqs-team-change"

  # Queue configuration
  sqs_name        = "sw-cp-testing-sqs-four"
  encrypt_sqs_kms = "false"
  use_team_name = true

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

resource "kubernetes_secret" "steve_test_sqs_four" {
  metadata {
    name      = "sqs-four"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.steve_test_sqs_four.sqs_id
    sqs_arn  = module.steve_test_sqs_four.sqs_arn
    sqs_name = module.steve_test_sqs_four.sqs_name
  }
}
