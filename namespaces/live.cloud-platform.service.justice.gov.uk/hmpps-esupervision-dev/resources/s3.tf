module "s3_data_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  cors_rule =[
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://esupervision-dev.hmpps.service.justice.gov.uk","https://manage-people-on-probation-dev.hmpps.service.justice.gov.uk/","http://localhost:3000/"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}

# info about the bucket
resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "hmpps-esupervision-data-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_data_bucket.bucket_arn
    bucket_name = module.s3_data_bucket.bucket_name
  }
}
