module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.email
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["https://*.apps.live-1.cloud-platform.service.justice.gov.uk", "https://find-legal-advice.justice.gov.uk"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}

module "cla_fala_static_files_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  acl                           = "public-read"
  enable_allow_block_pub_access = false
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
      allowed_origins = ["https://*.apps.live-1.cloud-platform.service.justice.gov.uk", "https://find-legal-advice.justice.gov.uk"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3.bucket_arn
    bucket_name = module.s3.bucket_name
    region      = "eu-west-2"
  }
}
