module "hmpps_prisoner_audit_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0" # use the latest release

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
  log_target_bucket      = module.hmpps_prisoner_audit_s3_logging_bucket
  log_path               = "logs/"
}


# Sets the governance mode to 1 day for testing on dev
resource "aws_s3_bucket_object_lock_configuration" "hmpps_prisoner_audit_s3_lock_configuration" {
  bucket = module.hmpps_prisoner_audit_s3.bucket_name

  rule {
    default_retention {
      mode  = "GOVERNANCE"
      years = 25
    }
  }

  depends_on = [
    module.hmpps_prisoner_audit_s3
  ]

}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "hmpps_prisoner_audit_s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps_prisoner_audit_s3.bucket_arn
    bucket_name = module.hmpps_prisoner_audit_s3.bucket_name
  }
}
