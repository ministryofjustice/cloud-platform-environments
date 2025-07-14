################################################################################
# Create and Vary a Licence
# S3 Bucket for file uploads
#################################################################################

module "create-and-vary-a-licence-s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
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

resource "kubernetes_secret" "create-and-vary-a-licence-s3" {
  metadata {
    name      = "create-and-vary-a-licence-s3-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.create-and-vary-a-licence-s3.bucket_arn
    bucket_name = module.create-and-vary-a-licence-s3.bucket_name
  }
}
