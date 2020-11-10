module "opseng_reports" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1.3"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = "true"
  namespace              = var.namespace

  hash_key          = "filename"
  enable_encryption = "false"
  enable_autoscaler = "true"
  aws_region        = "eu-west-2"
}

resource "kubernetes_secret" "opseng_reports" {
  metadata {
    name      = "opseng-reports-table"
    namespace = var.namespace
  }

  data = {
    table_name        = module.opseng_reports.table_name
    table_arn         = module.opseng_reports.table_arn
    access_key_id     = module.opseng_reports.access_key_id
    secret_access_key = module.opseng_reports.secret_access_key
  }
}
