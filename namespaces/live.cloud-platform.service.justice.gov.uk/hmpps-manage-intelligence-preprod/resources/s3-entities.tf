module "mercury_data_entities_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "mercury_data_entities_bucket" {
  metadata {
    name      = "mercury-data-entities-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.mercury_data_entities_bucket.bucket_arn
    bucket_name = module.mercury_data_entities_bucket.bucket_name
  }
}