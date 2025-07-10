module "emds_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}


resource "kubernetes_secret" "emds_s3" {
  metadata {
    name      = "emds-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.emds_s3.bucket_arn
    bucket_name = module.emds_s3.bucket_name
  }
}
