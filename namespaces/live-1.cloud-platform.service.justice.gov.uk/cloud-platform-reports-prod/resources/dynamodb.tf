module "cloud_platform_reports_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1.3"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = "false"
  namespace              = var.namespace

  hash_key          = "filename"
  enable_encryption = "false"
  enable_autoscaler = "true"
  aws_region        = "eu-west-2"
}

resource "kubernetes_secret" "cloud_platform_reports_dynamodb" {
  metadata {
    name      = "cloud-platform-reports-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.cloud_platform_reports_dynamodb.table_name
    table_arn         = module.cloud_platform_reports_dynamodb.table_arn
    access_key_id     = module.cloud_platform_reports_dynamodb.access_key_id
    secret_access_key = module.cloud_platform_reports_dynamodb.secret_access_key
  }
}
