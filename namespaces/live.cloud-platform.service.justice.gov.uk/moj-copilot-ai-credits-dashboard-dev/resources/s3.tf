module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

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
        "AWS": "arn:aws:iam::082282578003:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_modernisation-platform-sandbox_befb4340ef5f2771"
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
      "Sid": "S3DataSyncAccessAPAirflowDev",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::593291632749:role/airflow-development-coat-get-copilot-data"
      },
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    },
    {
      "Sid": "AthenaAccess",
      "Effect": "Allow",
      "Principal": {
          "Service": [
            "glue.amazonaws.com",
            "athena.amazonaws.com"
          ]
      },
      "Action": [
        "s3:PutObject",
        "s3:ListMultipartUploadParts",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetBucketLocation",
        "s3:AbortMultipartUpload"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ],
      "Condition": {
        "StringEquals": {
            "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    },
    {
      "Sid": "IRSARoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cloud-platform-irsa-df7faf623217f7f2-live"
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
    }
  ]
}
EOF
}

module "copilot_credits_auth0_tf_state_dev_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

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
      "Sid": "COATMPDevAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::082282578003:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_modernisation-platform-sandbox_befb4340ef5f2771"
      },
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF

  oidc_providers = ["github"]
  github_repositories = ["moj-copilot-ai-credits-dashboard"]

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-copilot-credits-auth0-tf-state-dev"
      abort_incomplete_multipart_upload_days = 90
      expiration = [
        {
          days = 30
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 30
        },
      ]
    },
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