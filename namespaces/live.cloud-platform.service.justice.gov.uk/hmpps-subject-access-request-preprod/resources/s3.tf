module "hmpps-subject-access-request_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0" # use the latest release

  # S3 configuration
  versioning = true

  providers = {
    aws = aws.london
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

}

resource "aws_s3_bucket_object_lock_configuration" "s3_bucket_lock_configuration" {
  bucket = module.hmpps-subject-access-request_s3_bucket.bucket_name

  rule {
    default_retention {
      mode = "GOVERNANCE"
        days = 1
    }
  }

  depends_on = [
    module.hmpps-subject-access-request_s3_bucket
  ]

}

resource "kubernetes_secret" "hmpps-subject-access-request_s3_bucket" {
  metadata {
    name      = "hmpps-subject-access-request-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps-subject-access-request_s3_bucket.bucket_arn
    bucket_name = module.hmpps-subject-access-request_s3_bucket.bucket_name
  }
}
