module "drupal_content_storage" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

  team_name              = var.team_name
  versioning             = true
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  # S3 was provisioned before we changed the default region to London
  # so if this isn't set we get a 301 error when it tries to rebuild it
  namespace = var.namespace

  # Add CORS rule to allow direct s3 file uploading with progress bar (in Drupal CMS).
  cors_rule = [
    {
      allowed_headers = ["Accept", "Content-Type", "Origin"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://manage.content-hub.prisoner.service.justice.gov.uk"]
      max_age_seconds = 3000
    }
  ]

  providers = {
    aws = aws.ireland
  }

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowHubProductionS3SyncNew",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/s3-bucket-user-ee432bcfffe38a157f08669a6d4b7740"
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    },
    {
      "Sid": "AllowHubDevelopmentS3SyncNew",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/s3-bucket-user-0da9568a0aa6b9444b6fb48e8d4f79cd"
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    },
    {
      "Sid": "AllowHubStagingS3Sync",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/s3-bucket-user-c3b3fc90408e8f9501268e354d44f461"
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    },
    {
      "Sid": "AllowListBucketVersions",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/s3-bucket-user-5e5f7ac99afe21a0181cbf50a850627b"
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

# Output S3 bucket info to staging and development namespaces, to facilitate automated file syncing.
# NOTE: We only share the bucket name.  We never share access keys.
resource "kubernetes_secret" "drupal_content_storage_output_staging" {
  metadata {
    name      = "drupal-s3-output"
    namespace = "prisoner-content-hub-staging"
  }

  data = {
    bucket_name = module.drupal_content_storage.bucket_name
  }
}
resource "kubernetes_secret" "drupal_content_storage_output_development" {
  metadata {
    name      = "drupal-s3-output"
    namespace = "prisoner-content-hub-development"
  }

  data = {
    bucket_name = module.drupal_content_storage.bucket_name
  }
}
# Temporarily output to production as well, so we can sync from old to new buckets
# until we're ready to cut over to the new one.
resource "kubernetes_secret" "drupal_content_storage_output_production" {
  metadata {
    name      = "drupal-s3-output"
    namespace = "prisoner-content-hub-production"
  }

  data = {
    bucket_name = module.drupal_content_storage.bucket_name
  }
}
