module "perf-test-data-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = "cpmg-gatling-performance-tests"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "perf-test-data-s3-secret" {
  metadata {
    name      = "perf-test-data-s3-credentials"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.perf-test-data-s3-bucket.bucket_arn
    bucket_name = module.perf-test-data-s3-bucket.bucket_name
  }
}
