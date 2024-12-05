/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace
  enable_allow_block_pub_access = false

  bucket_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:sts::754256621582:assumed-role/access-via-github/matt-k1998"
          ]
        },
        "Action": [
          "s3:PutObject"
        ],
        "Resource": [
          "$${bucket_arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "$${bucket_arn}/*"
        ]
      }
    ]
  }
  EOF

  providers = {
    aws = aws.london
  }
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
