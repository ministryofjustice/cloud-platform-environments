module "crime_portal_gateway_s3_bucket" {
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

resource "kubernetes_secret" "crime_portal_gateway_s3_secret" {
  metadata {
    name      = "crime_portal_gateway_s3_credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.crime_portal_gateway_s3_bucket.access_key_id
    bucket_arn        = module.crime_portal_gateway_s3_bucket.bucket_arn
    bucket_name       = module.crime_portal_gateway_s3_bucket.bucket_name
    secret_access_key = module.crime_portal_gateway_s3_bucket.secret_access_key
  }
}

