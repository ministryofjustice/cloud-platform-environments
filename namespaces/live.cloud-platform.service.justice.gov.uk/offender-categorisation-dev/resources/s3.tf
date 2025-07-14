module "risk_profiler_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "risk_profiler_s3_bucket" {
  metadata {
    name      = "risk-profiler-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.risk_profiler_s3_bucket.bucket_arn
    bucket_name = module.risk_profiler_s3_bucket.bucket_name
  }
}
