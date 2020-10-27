/*
 Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/master/example
 */
module "calculate-journey-variable-payments_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"

  team_name              = var.team_name
  business-unit          = "Digital and Technology"
  application            = var.application
  infrastructure-support = var.infrastructure-support

  is-production    = var.is-production
  environment-name = var.environment-name
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
    access_key_id     = module.calculate-journey-variable-payments_s3_bucket.access_key_id
    secret_access_key = module.calculate-journey-variable-payments_s3_bucket.secret_access_key
    bucket_arn        = module.calculate-journey-variable-payments_s3_bucket.bucket_arn
    bucket_name       = module.calculate-journey-variable-payments_s3_bucket.bucket_name
  }
}
