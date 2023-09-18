module "report_id_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  enable_autoscaler            = "false"
  autoscale_min_read_capacity  = null
  autoscale_min_write_capacity = null
  hash_key                     = "id"
  hash_key_type                = "N"
  billing_mode                 = "PAY_PER_REQUEST"
}

resource "kubernetes_secret" "report_id_dynamodb" {
  metadata {
    name      = "report-id-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name = module.report_id_dynamodb.table_name
    table_arn  = module.report_id_dynamodb.table_arn
  }
}
