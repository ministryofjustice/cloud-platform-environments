module "drupal_content_storage_2" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # Add CORS rule to allow direct s3 file uploading with progress bar (in Drupal CMS).
  cors_rule = [
    {
      allowed_headers = ["Accept", "Content-Type", "Origin"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://cms-prisoner-content-hub-development.apps.live.cloud-platform.service.justice.gov.uk"]
      max_age_seconds = 3000
    }
  ]
}

resource "kubernetes_secret" "drupal_content_storage_2_secret" {
  metadata {
    name      = "drupal-s3-2"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.drupal_content_storage_2.bucket_arn
    bucket_name       = module.drupal_content_storage_2.bucket_name
  }
}
