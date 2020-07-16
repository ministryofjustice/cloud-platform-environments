module "mps_storage_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.3"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "mps_storage_s3_bucket" {
  metadata {
    name      = "mps-storage-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.mps_storage_s3_bucket.access_key_id
    secret_access_key = module.mps_storage_s3_bucket.secret_access_key
    bucket_arn        = module.mps_storage_s3_bucket.bucket_arn
    bucket_name       = module.mps_storage_s3_bucket.bucket_name
  }
}

