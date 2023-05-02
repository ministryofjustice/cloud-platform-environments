module "sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=HEAT-61-test-irsa"

  # SQS configuration
  encrypt_sqs_kms = true
  sqs_name        = "jm-dev"

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
