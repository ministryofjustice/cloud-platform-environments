/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
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

  lifecycle_rule = [
    {
      id      = "Retire Processed files after 7 days"
      enabled = true
      prefix  = "processed/"

      expiration = [
        {
          days = 7
        }
      ]

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]

    },
    {
      id      = "Retire Errored files after 30 days"
      enabled = true
      prefix  = "errored/"

      expiration = [
        {
          days = 30
        }
      ]

      noncurrent_version_expiration = [
        {
          days = 30
        },
      ]

    }
  ]

}
