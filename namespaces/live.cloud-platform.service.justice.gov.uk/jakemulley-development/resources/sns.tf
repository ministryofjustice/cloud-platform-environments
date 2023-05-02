module "sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns?ref=4.8.0"

  # SNS configuration
  topic_display_name = "jm-dev"
  encrypt_sns_kms    = true

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
