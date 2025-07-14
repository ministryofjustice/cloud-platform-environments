module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "cdn_s3" {
  metadata {
    name      = "cdn-s3"
    namespace = var.namespace
  }

  data = {
    bucket_name = module.s3.bucket_name
  }
}
