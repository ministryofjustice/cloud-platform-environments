module "drupal_content_storage_2" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowHubDevelopmentS3Sync",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::754256621582:role/cloud-platform-irsa-ef2db18d7c57f6c9-live"
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
          "AWS": "arn:aws:iam::754256621582:role/cloud-platform-irsa-bdac39af1fc11901-live"
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
          "AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/s3-bucket-user-ee432bcfffe38a157f08669a6d4b7740"
      },
      "Action": [
        "s3:ListBucketVersions"
      ],
      "Resource": [
        "$${bucket_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/s3-bucket-user-ee432bcfffe38a157f08669a6d4b7740"
      },
      "Action": [
        "s3:GetObjectAcl",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF

  # Adds staging & old production S3 resources to user-policy to allow one-way sync
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
        "arn:aws:s3:::cloud-platform-c3b3fc90408e8f9501268e354d44f461",
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
        "arn:aws:s3:::cloud-platform-c3b3fc90408e8f9501268e354d44f461/*",
        "arn:aws:s3:::cloud-platform-5e5f7ac99afe21a0181cbf50a850627b/*"
      ]
    }
  ]
}
EOF
}

# Output S3 bucket info to staging and development namespaces, to facilitate automated file syncing.
# NOTE: We only share the bucket name.  We never share access keys.
resource "kubernetes_secret" "drupal_content_storage_output_staging_new" {
  metadata {
    name      = "drupal-s3-output-new"
    namespace = "prisoner-content-hub-staging"
  }

  data = {
    bucket_name = module.drupal_content_storage_2.bucket_name
  }
}
resource "kubernetes_secret" "drupal_content_storage_output_development_new" {
  metadata {
    name      = "drupal-s3-output-new"
    namespace = "prisoner-content-hub-development"
  }

  data = {
    bucket_name = module.drupal_content_storage_2.bucket_name
  }
}

resource "kubernetes_secret" "drupal_content_storage_2_secret" {
  metadata {
    name      = "drupal-s3-2"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.drupal_content_storage_2.bucket_arn
    bucket_name       = module.drupal_content_storage_2.bucket_name
  }
}
