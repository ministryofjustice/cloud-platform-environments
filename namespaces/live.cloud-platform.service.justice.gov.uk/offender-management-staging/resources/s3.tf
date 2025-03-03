/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = module.s3_bucket.bucket_name

  depends_on = [
    module.s3_bucket
  ]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "s3_bucket_lock_configuration" {
  bucket = module.s3_bucket.bucket_name

  depends_on = [
    module.s3_bucket
  ]
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}
