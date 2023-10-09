module "metadata_collection" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key                     = "name"
  enable_autoscaler            = "true"
  autoscale_max_read_capacity  = "100"
  autoscale_max_write_capacity = "100"
}

resource "kubernetes_secret" "metadata_collection" {
  metadata {
    name      = "dynamo-table-data"
    namespace = var.namespace
  }

  data = {
    table_name = module.metadata_collection.table_name
    table_arn  = module.metadata_collection.table_arn
  }
}
