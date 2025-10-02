module "s3-dev-test" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0" # use the latest release

  # S3 configuration

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "s3-dev-test" {
  metadata {
    name      = "s3-dev-test-output"
    namespace = var.namespace
  }

  data = {
    images_bucket_arn  = module.s3-dev-test.bucket_arn
    images_bucket_name = module.s3-dev-test.bucket_name
  }
}
