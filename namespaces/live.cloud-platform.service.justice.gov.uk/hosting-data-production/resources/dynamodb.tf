module "dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.2.1"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  aws_region             = "eu-west-2"
  namespace              = var.namespace

  hash_key  = "example-hash"
  range_key = "example-range"
}
