module "s3-images" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0" # use the latest release

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

resource "kubernetes_secret" "s3-images" {
  metadata {
    name      = "s3-images-output"
    namespace = var.namespace
  }

  data = {
    images_bucket_arn  = module.s3-images.bucket_arn
    images_bucket_name = module.s3-images.bucket_name
  }
}
