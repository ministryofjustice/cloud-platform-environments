module "cla_frontend_static_files_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment-name
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace

  providers = {
    aws = aws.london
  }
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["https://*.apps.live-1.cloud-platform.service.justice.gov.uk", "uat.cases.civillegaladvice.service.gov.uk"]
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
    static_files_bucket_name = module.cla_frontend_static_files_bucket.bucket_name
    static_files_bucket_arn  = module.cla_frontend_static_files_bucket.bucket_arn
  }
}
