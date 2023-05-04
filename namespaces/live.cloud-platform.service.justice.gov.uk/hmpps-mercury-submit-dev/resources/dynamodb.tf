module "report_id_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.5.2"

  team_name                    = var.team_name
  application                  = var.application
  business-unit                = var.business_unit
  environment-name             = var.environment-name
  infrastructure-support       = var.infrastructure_support
  is-production                = "false"
  namespace                    = var.namespace

  hash_key      = "id"
  hash_key_type = "N"
  billing_mode  = "PAY_PER_REQUEST"
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