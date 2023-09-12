module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.0.0"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
      aws = aws.london
  }
}

resource "kubernetes_secret" "consider-a-recall-s3" {
  metadata {
    name      = "consider-a-recall-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.consider-a-recall-s3.bucket_arn
    bucket_name = module.consider-a-recall-s3.bucket_name
  }
}