module "s3-bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  acl                    = "private"

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire submission results after 7 days"
      prefix  = "submission/result"

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]
      expiration = [
        {
          days = 7
        },
      ]
    }
  ]
}

resource "kubernetes_secret" "s3-bucket" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    bucket_name = module.s3-bucket.bucket_name
    bucket_arn  = module.s3-bucket.bucket_arn
  }
}
