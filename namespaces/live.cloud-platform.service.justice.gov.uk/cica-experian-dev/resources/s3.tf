module "bankwizard_artifact_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

  # S3 configuration
  versioning = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "bankwizard_artifact_bucket" {
  metadata {
    name      = "bankwizard-artifact-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.bankwizard_artifact_bucket.bucket_arn
    bucket_name = module.bankwizard_artifact_bucket.bucket_name
  }
}
