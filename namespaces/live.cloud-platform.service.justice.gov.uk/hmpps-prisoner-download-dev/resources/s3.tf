module "hmpps-prisoner-download_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = { aws = aws.london }

  lifecycle_rule = [
    {
      enabled    = true
      id         = "expire all downloads after 14 days"
      expiration = [{ days = 14 }]
    },
  ]
}

resource "kubernetes_secret" "hmpps-prisoner-download_s3_bucket" {
  metadata {
    name      = "hmpps-prisoner-download-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps-prisoner-download_s3_bucket.bucket_arn
    bucket_name = module.hmpps-prisoner-download_s3_bucket.bucket_name
  }
}
