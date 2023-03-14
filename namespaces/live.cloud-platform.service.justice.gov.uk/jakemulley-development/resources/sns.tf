module "sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.7.0"

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Module variabes
  encrypt_sns_kms    = "true"
  topic_display_name = "jmdev"
}
