module "cica_versions_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.email
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cica_versions_bucket" {
  metadata {
    name      = "cica_versions_bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.cica_versions_bucket.bucket_arn
    bucket_name = module.cica_versions_bucket.bucket_name
  }
}
