module "hmpps-workload-prod-s3-dashboard-bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  versioning = true

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire extracts after 2 weeks"
      prefix  = "generated-dashboards/"
      noncurrent_version_expiration = [
        {
          days = 14
        },
      ]
      expiration = [
        {
          days = 14
        },
      ]
    }
  ]


}

resource "kubernetes_secret" "hmpps-workload-prod-s3-dashboard-bucket" {
  metadata {
    name      = "s3-dashboard-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps-workload-prod-s3-dashboard-bucket.bucket_arn
    bucket_name = module.hmpps-workload-prod-s3-dashboard-bucket.bucket_name
  }
}
