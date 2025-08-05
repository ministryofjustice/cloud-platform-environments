module "dynamodb-fci-prod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.1.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key          = "pk"
  range_key         = "sk"
  enable_encryption = "true"
  enable_autoscaler = "true"

  attributes = [
    {
      name = "pk"
      type = "S"
    },
    {
      name = "sk"
      type = "S"
    },
    {
      name = "review_status"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "review_status_index"
      hash_key        = "review_status"
      range_key       = "sk"
      projection_type = "ALL"
      read_capacity   = 5
      write_capacity  = 5
    }
  ]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dynamodb-fci-prod" {
  metadata {
    name      = "dynamodb-fci-prod-output"
    namespace = var.namespace
  }

  data = {
    table_name = module.dynamodb-fci-prod.table_name
    table_arn  = module.dynamodb-fci-prod.table_arn
  }
}
