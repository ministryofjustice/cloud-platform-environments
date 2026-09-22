module "holds-restore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  # S3 configuration

  # Tags
  application            = "hmpps-prisoner-finance-holds-api"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "s3-db-restore" {
  metadata {
    name      = "holds-restore-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.holds-restore-s3-bucket.bucket_arn
    bucket_name = module.holds-restore-s3-bucket.bucket_name
  }
}
