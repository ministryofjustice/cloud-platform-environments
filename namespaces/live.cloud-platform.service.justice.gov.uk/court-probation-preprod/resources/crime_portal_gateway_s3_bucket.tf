module "crime-portal-gateway-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = "crime-portal-gateway"
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-28d"
      abort_incomplete_multipart_upload_days = 28
      expiration = [
        {
          days = 28
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 28
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
    access_key_id     = module.crime-portal-gateway-s3-bucket.access_key_id
    bucket_arn        = module.crime-portal-gateway-s3-bucket.bucket_arn
    bucket_name       = module.crime-portal-gateway-s3-bucket.bucket_name
    secret_access_key = module.crime-portal-gateway-s3-bucket.secret_access_key
  }
}
