module "opseng_reports" {
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

resource "kubernetes_secret" "opseng_reports" {
  metadata {
    name      = "opseng-reports-table"
    namespace = var.namespace
  }

  data = {
    table_name = module.opseng_reports.table_name
    table_arn  = module.opseng_reports.table_arn
  }
}
