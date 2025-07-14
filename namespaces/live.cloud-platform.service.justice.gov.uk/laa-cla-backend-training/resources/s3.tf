module "cla_backend_private_reports_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  acl    = "private"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "Remove reports after 2 years"
      prefix  = "exports/"

      expiration = [
        {
          days = 730
        },
      ]

      noncurrent_version_expiration = [
        {
          days = 730
        },
      ]
    }
  ]

}

module "cla_backend_deleted_objects_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  acl    = "private"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

}


module "cla_backend_static_files_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
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
      allowed_origins = ["https://*.apps.live-1.cloud-platform.service.justice.gov.uk", "https://training.fox.civillegaladvice.service.gov.uk"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}


resource "kubernetes_secret" "cla_backend_s3" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    reports_bucket_arn          = module.cla_backend_private_reports_bucket.bucket_arn
    reports_bucket_name         = module.cla_backend_private_reports_bucket.bucket_name
    deleted_objects_bucket_arn  = module.cla_backend_deleted_objects_bucket.bucket_arn
    deleted_objects_bucket_name = module.cla_backend_deleted_objects_bucket.bucket_name
    static_files_bucket_name    = module.cla_backend_static_files_bucket.bucket_name
    static_files_bucket_arn     = module.cla_backend_static_files_bucket.bucket_arn
  }
}
