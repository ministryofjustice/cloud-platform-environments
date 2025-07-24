module "s3" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  bucket_name = var.s3_bucket_name
  versioning  = true

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace

  event_notifications = {
    event_name = "s3:ObjectCreated:*"
    topics     = [module.sns_topic_file_upload.arn]
  }

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "people-and-events-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3.bucket_arn
    bucket_name = module.s3.bucket_name
  }
}
