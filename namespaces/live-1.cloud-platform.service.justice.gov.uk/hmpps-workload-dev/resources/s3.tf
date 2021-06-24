module "hmpps-workload-dev-s3-bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  versioning = true

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire extracts after 30 days"
      prefix  = "extract/"
      noncurrent_version_expiration = [
        {
          days = 30
        },
      ]
      expiration = [
        {
          days = 30
        },
      ]
    }
  ]
  
}

resource "kubernetes_secret" "hmpps-workload-dev-s3-bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps-workload-dev-s3-bucket.access_key_id
    secret_access_key = module.hmpps-workload-dev-s3-bucket.secret_access_key
    bucket_arn        = module.hmpps-workload-dev-s3-bucket.bucket_arn
    bucket_name       = module.hmpps-workload-dev-s3-bucket.bucket_name
  }
}
