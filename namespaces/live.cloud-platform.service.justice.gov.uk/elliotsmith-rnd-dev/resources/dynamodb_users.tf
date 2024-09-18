module "dynamodb_users_table" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  hash_key  = "guid"
  range_key = "created_at"
  attributes = [
    {
      name = "guid"
      type = "S"
    },
    {
      name = "created_at"
      type = "S"
    }
  ]
}

resource "kubernetes_secret" "dynamodb_users_table_output" {
  metadata {
    name      = "dynamodb_users_table_output"
    namespace = var.namespace
  }

  data = {
    table_name = module.dynamodb_users_table.table_name
    table_arn  = module.dynamodb_users_table.table_arn
  }
}
