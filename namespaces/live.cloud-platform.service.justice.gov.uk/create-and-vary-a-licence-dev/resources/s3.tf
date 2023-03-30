################################################################################
# Create and Vary a Licence
# S3 Bucket for file uploads
#################################################################################

module "create-and-vary-a-licence-s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "create-and-vary-a-licence-s3" {
  metadata {
    name      = "create-and-vary-a-licence-s3-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.create-and-vary-a-licence-s3.access_key_id
    secret_access_key = module.create-and-vary-a-licence-s3.secret_access_key
    bucket_arn        = module.create-and-vary-a-licence-s3.bucket_arn
    bucket_name       = module.create-and-vary-a-licence-s3.bucket_name
  }
}

