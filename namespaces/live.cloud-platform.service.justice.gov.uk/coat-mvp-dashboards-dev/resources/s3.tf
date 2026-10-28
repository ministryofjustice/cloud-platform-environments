module "coh_export_daily_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3DataSyncAccessMPDev",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::082282578003:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_modernisation-platform-developer_3ce90653088957a1"
      },
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    },
    {
      "Sid": "IRSARoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${module.mvp_dashboards.role_arn}"
      },
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "bcm-data-exports.amazonaws.com"
      },
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketAcl",
        "s3:GetBucketPolicy"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": [
            "295814833350"
          ]
        }
      }
    }
  ]
}
EOF
}

resource "kubernetes_secret" "coh_export_daily_bucket" {
  metadata {
    name      = "coh-export-daily-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.coh_export_daily_bucket.bucket_arn
    bucket_name = module.coh_export_daily_bucket.bucket_name
  }
}