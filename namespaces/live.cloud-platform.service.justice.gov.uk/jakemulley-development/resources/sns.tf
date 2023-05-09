module "sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns?ref=4.9.0"

  # Configuration
  encrypt_sns_kms    = true
  topic_display_name = "jm-dev"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
