module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0" # use the latest release

  # S3 configuration
  versioning = true
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  logging_enabled        = true
  log_target_bucket      = module.s3_logging_bucket.bucket_name
  log_path               = "logs/"
}


resource "aws_s3_bucket_object_lock_configuration" "s3_bucket_lock_configuration" {
  bucket = module.s3.bucket_name

  rule {
    default_retention {
      mode  = "GOVERNANCE"
      years = 25
    }
  }

  depends_on = [
    module.s3
  ]

}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3.bucket_arn
    bucket_name = module.s3.bucket_name
  }
}

