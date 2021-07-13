# Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/master/example
module "manage_recalls_s3_bucket_dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  infrastructure-support = var.infrastructure_support

  is-production    = var.is_production
  environment-name = var.environment
  namespace        = var.namespace

  providers = {
    aws = aws.london
  }

  versioning = false
}

resource "kubernetes_secret" "manage_recalls_s3_bucket_dev" {
  metadata {
    name      = "manage-recalls-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.manage_recalls_s3_bucket_dev.access_key_id
    secret_access_key = module.manage_recalls_s3_bucket_dev.secret_access_key
    bucket_arn        = module.manage_recalls_s3_bucket_dev.bucket_arn
    bucket_name       = module.manage_recalls_s3_bucket_dev.bucket_name
  }
}
