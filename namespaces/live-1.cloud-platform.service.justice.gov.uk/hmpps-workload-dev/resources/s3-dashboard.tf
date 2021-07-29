module "hmpps-workload-dev-s3-dashboard-bucket" {

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
      id      = "retire extracts after 180 days"
      prefix  = "extract/"
      noncurrent_version_expiration = [
        {
          days = 180
        },
      ]
      expiration = [
        {
          days = 180
        },
      ]
    }
  ]


}

resource "kubernetes_secret" "hmpps-workload-dev-s3-dashboard-bucket" {
  metadata {
    name      = "s3-dashboard-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps-workload-dev-s3-dashboard-bucket.access_key_id
    secret_access_key = module.hmpps-workload-dev-s3-dashboard-bucket.secret_access_key
    bucket_arn        = module.hmpps-workload-dev-s3-dashboard-bucket.bucket_arn
    bucket_name       = module.hmpps-workload-dev-s3-dashboard-bucket.bucket_name
  }
}
