module "hmcts-data-ingestion-s3-bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "hmcts-data-ingestion-s3-bucket" {
  metadata {
    name      = "hmcts-data-ingestion-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmcts-data-ingestion-s3-bucket.bucket_arn
    bucket_name = module.hmcts-data-ingestion-s3-bucket.bucket_name
  }
}
