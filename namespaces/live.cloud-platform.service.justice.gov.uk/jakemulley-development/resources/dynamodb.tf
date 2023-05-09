module "dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.5.2"

  # Configuration
  hash_key = "pk"

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
