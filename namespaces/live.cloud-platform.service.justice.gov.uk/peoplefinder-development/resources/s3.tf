################################################################################
# People Finder
# S3 Bucket for file uploads
#################################################################################

module "peoplefinder_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "POST", "PUT"]
      allowed_origins = [
        "https://development.peoplefinder.service.gov.uk"
      ]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["Authorization"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
  ]
  namespace = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "peoplefinder_s3" {
  metadata {
    name      = "peoplefinder-s3-output"
    namespace = var.namespace
  }

  data = {
    bucket_name = module.peoplefinder_s3.bucket_name
  }
}
