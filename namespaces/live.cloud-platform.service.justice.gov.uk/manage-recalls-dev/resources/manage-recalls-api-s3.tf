##
## Manage Recalls Document Storage
##

# Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/master/example
module "manage_recalls_api_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  environment-name       = var.environment
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  versioning = false
}

resource "kubernetes_secret" "manage_recalls_api_s3_bucket" {
  metadata {
    name      = "manage-recalls-api-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.manage_recalls_api_s3_bucket.access_key_id
    secret_access_key = module.manage_recalls_api_s3_bucket.secret_access_key
    bucket_arn        = module.manage_recalls_api_s3_bucket.bucket_arn
    bucket_name       = module.manage_recalls_api_s3_bucket.bucket_name
  }
}
