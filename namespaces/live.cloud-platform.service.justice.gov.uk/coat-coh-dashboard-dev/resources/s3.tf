module "coat_coh_dashboard_auth0_tf_state_dev_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  oidc_providers = ["github"]
  github_repositories = ["coat-coh-dashboard"]
  github_actions_prefix = "DEV"

  versioning = true
  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-3rd-noncurrent-version"
      abort_incomplete_multipart_upload_days = 90
      noncurrent_version_expiration = [
        {
          days = 30
          newer_noncurrent_versions = 2
        },
      ]
    },
  ]
}

module "coh_export_daily_csv_bucket" {
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
        "AWS": "${module.irsa.role_arn}"
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

resource "kubernetes_secret" "coat_coh_dashboard_auth0_tf_state_dev_s3_bucket" {
  metadata {
    name      = "coat-coh-dashboard-auth0-tf-state-dev-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.coat_coh_dashboard_auth0_tf_state_dev_s3_bucket.bucket_arn
    bucket_name = module.coat_coh_dashboard_auth0_tf_state_dev_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "coh_export_daily_csv_bucket" {
  metadata {
    name      = "coh-export-daily-csv-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.coh_export_daily_csv_bucket.bucket_arn
    bucket_name = module.coh_export_daily_csv_bucket.bucket_name
  }
}