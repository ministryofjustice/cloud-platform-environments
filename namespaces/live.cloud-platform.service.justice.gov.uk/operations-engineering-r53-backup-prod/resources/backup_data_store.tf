module "backup_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  lifecycle_rule = [
    {
      enabled = true

      expiration {
        days = 30
      }
    }
  ]
}

resource "kubernetes_secret" "backup_s3_bucket" {
  metadata {
    name      = "backup-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.backup_s3_bucket.bucket_arn
    bucket_name = module.backup_s3_bucket.bucket_name
  }
}
