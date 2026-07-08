/*
 Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/master/example
 */
module "calculate-journey-variable-payments_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = "Digital and Technology"
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment-name
  namespace        = var.namespace

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

  versioning = false
}

resource "kubernetes_secret" "calculate-journey-variable-payments_s3_bucket" {
  metadata {
    name      = "calculate-journey-variable-payments-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.calculate-journey-variable-payments_s3_bucket.bucket_arn
    bucket_name = module.calculate-journey-variable-payments_s3_bucket.bucket_name
  }
}
