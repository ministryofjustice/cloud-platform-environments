/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  versioning = true

  bucket_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
            "AWS": "*"
        },
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      }
    ]
  }
  EOF

  # Tags
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "s3_fb_metadata_backup_test" {
  metadata {
    name      = "s3-fb-metadata-backup-test"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}
