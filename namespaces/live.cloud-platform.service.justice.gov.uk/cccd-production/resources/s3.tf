/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "cccd_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cccd_s3_bucket" {
  metadata {
    name      = "cccd-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.cccd_s3_bucket.bucket_arn
    bucket_name = module.cccd_s3_bucket.bucket_name
  }
}
