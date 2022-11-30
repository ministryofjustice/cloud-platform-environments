module "dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=add-gsi"

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

module "dynamodb_with_gsi" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=add-gsi"

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

  global_secondary_indexes = [
    {
      name               = "GameTitleIndex"
      hash_key           = "GameTitle"
      range_key          = "TopScore"
      write_capacity     = 10
      read_capacity      = 10
      projection_type    = "INCLUDE"
      non_key_attributes = ["UserId"]
    }
  ]
}
