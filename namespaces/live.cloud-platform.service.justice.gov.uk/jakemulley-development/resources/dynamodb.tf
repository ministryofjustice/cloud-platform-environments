module "dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.4.0"

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Table attributes
  hash_key = "hk"
}
