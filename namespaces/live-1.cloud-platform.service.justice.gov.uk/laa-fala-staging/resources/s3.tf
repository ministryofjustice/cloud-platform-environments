module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.email
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "cla_fala_static_files_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7"
  acl                           = "public-read"
  enable_allow_block_pub_access = false
  team_name                     = var.team_name
  business-unit                 = var.business-unit
  application                   = var.application
  is-production                 = var.is-production
  environment-name              = var.environment-name
  infrastructure-support        = var.infrastructure-support
  namespace                     = var.namespace

  providers = {
    aws = aws.london
  }
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["https://*.apps.live-1.cloud-platform.service.justice.gov.uk", "https://staging.find-legal-advice.justice.gov.uk"]
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
    access_key_id     = module.s3.access_key_id
    secret_access_key = module.s3.secret_access_key
    bucket_arn        = module.s3.bucket_arn
    bucket_name       = module.s3.bucket_name
    region            = "eu-west-2"
  }
}



