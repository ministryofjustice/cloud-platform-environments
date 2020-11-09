module "crime-portal-gateway-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = "crime-portal-gateway"
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
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

