module "report_id_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.5.2"

  team_name                    = var.team_name
  application                  = var.application
  business-unit                = var.business_unit
  environment-name             = var.environment
  infrastructure-support       = var.infrastructure_support
  is-production                = "false"
  namespace                    = var.namespace

  enable_autoscaler            = "false"
  autoscale_min_read_capacity  = null
  autoscale_min_write_capacity = null
  hash_key                     = "id"
  hash_key_type                = "N"
  billing_mode                 = "PAY_PER_REQUEST"
}

resource "aws_dynamodb_table_item" "id" {
  table_name = module.report_id_dynamodb.table_name
  hash_key   = module.report_id_dynamodb.hash_key

  item = <<ITEM
{
  "id": {"N": "0"},
  "num": {"N": "40000000"}
}
ITEM
}

resource "kubernetes_secret" "report_id_dynamodb" {
  metadata {
    name      = "report-id-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.report_id_dynamodb.table_name
    table_arn         = module.report_id_dynamodb.table_arn
    access_key_id     = module.report_id_dynamodb.access_key_id
    secret_access_key = module.report_id_dynamodb.secret_access_key
  }
}