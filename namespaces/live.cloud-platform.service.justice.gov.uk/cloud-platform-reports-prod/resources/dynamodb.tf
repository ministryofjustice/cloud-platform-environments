module "cloud_platform_reports_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key          = "filename"
  enable_encryption = "false"
  enable_autoscaler = "true"
}

resource "kubernetes_secret" "cloud_platform_reports_dynamodb" {
  metadata {
    name      = "cloud-platform-reports-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name = module.cloud_platform_reports_dynamodb.table_name
    table_arn  = module.cloud_platform_reports_dynamodb.table_arn
  }
}
