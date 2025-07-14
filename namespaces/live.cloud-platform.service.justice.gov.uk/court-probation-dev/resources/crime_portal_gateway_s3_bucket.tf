module "crime-portal-gateway-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = "crime-portal-gateway"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-crime-portal-gateway-bucket"
      abort_incomplete_multipart_upload_days = 90
      expiration = [
        {
          days = 90
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 90
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "crime-portal-gateway-s3-secret" {
  metadata {
    name      = "crime-portal-gateway-s3-credentials"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.crime-portal-gateway-s3-bucket.bucket_arn
    bucket_name = module.crime-portal-gateway-s3-bucket.bucket_name
  }
}
