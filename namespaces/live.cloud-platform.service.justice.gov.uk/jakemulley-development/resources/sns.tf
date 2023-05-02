module "sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=HEAT-61-test-irsa"

  # SNS configuration
  topic_display_name = "jm-dev"
  encrypt_sns_kms    = true

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
