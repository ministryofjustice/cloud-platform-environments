module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0" # use the latest release

  # S3 configuration

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = module.s3.bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

# Sets the governance mode to 1 day for testing on dev
resource "aws_s3_bucket_object_lock_configuration" "s3_bucket_lock_configuration" {
  bucket = module.s3.bucket_name

  rule {
    default_retention {
      mode = "GOVERNANCE"
        days = 1
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.s3_bucket_versioning
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
