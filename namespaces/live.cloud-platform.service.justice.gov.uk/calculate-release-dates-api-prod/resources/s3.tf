module "db_restore_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1" # use latest release

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3-db-restore-bucket"
    namespace = var.namespace
  }
  data = {
    bucket_arn  = module.db_restore_s3.bucket_arn
    bucket_name = module.db_restore_s3.bucket_name
  }
}