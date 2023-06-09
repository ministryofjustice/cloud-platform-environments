module "drupal_content_storage" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

  team_name              = var.team_name
  versioning             = true
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # Add CORS rule to allow direct s3 file uploading with progress bar (in Drupal CMS).
  cors_rule = [
    {
      allowed_headers = ["Accept", "Content-Type", "Origin"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://cms-prisoner-content-hub-staging.apps.live.cloud-platform.service.justice.gov.uk"]
      max_age_seconds = 3000
    }
  ]

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListBucketVersions",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/s3-bucket-user-c3b3fc90408e8f9501268e354d44f461"
      },
      "Action": [
        "s3:ListBucketVersions"
      ],
      "Resource": [
        "$${bucket_arn}"
      ]
    }
  ]
}
EOF

  # Adds production S3 resources to user-policy to allow one-way sync
  # https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket#migrate-from-existing-buckets
  user_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "$${bucket_arn}",
        "arn:aws:s3:::cloud-platform-5e5f7ac99afe21a0181cbf50a850627b"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "$${bucket_arn}/*",
        "arn:aws:s3:::cloud-platform-5e5f7ac99afe21a0181cbf50a850627b/*"
      ]
    }
  ]
}
EOF

}
resource "kubernetes_secret" "drupal_content_storage_secret" {
  metadata {
    name      = "drupal-s3"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.drupal_content_storage.access_key_id
    secret_access_key = module.drupal_content_storage.secret_access_key
    bucket_arn        = module.drupal_content_storage.bucket_arn
    bucket_name       = module.drupal_content_storage.bucket_name
  }
}
