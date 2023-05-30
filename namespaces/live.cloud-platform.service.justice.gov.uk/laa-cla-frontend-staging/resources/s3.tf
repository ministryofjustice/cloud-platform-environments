module "cla_frontend_static_files_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"
  acl                           = "public-read"
  enable_allow_block_pub_access = false
  team_name                     = var.team_name
  business-unit                 = var.business_unit
  application                   = var.application
  is-production                 = var.is_production
  environment-name              = var.environment-name
  infrastructure-support        = var.infrastructure_support
  namespace                     = var.namespace

  providers = {
    aws = aws.london
  }
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["https://staging.cases.civillegaladvice.service.gov.uk", "https://*.apps.live-1.cloud-platform.service.justice.gov.uk"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}


resource "kubernetes_secret" "cla_frontend_s3" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    access_key_id            = module.cla_frontend_static_files_bucket.access_key_id
    secret_access_key        = module.cla_frontend_static_files_bucket.secret_access_key
    static_files_bucket_name = module.cla_frontend_static_files_bucket.bucket_name
    static_files_bucket_arn  = module.cla_frontend_static_files_bucket.bucket_arn
  }
}
