module "manage_soc_cases_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = true
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  user_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration"
    ],
    "Resource": "$${bucket_arn}"
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectTagging",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTorrent",
      "s3:GetObjectTorrent",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:DeleteObjectTagging",
      "s3:RestoreObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ],
    "Resource": "$${bucket_arn}/*"
  }
]
}
EOF

}

module "manage_soc_cases_rds_to_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "manage_soc_cases_document_s3_bucket" {
  metadata {
    name      = "manage-soc-cases-document-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.manage_soc_cases_document_s3_bucket.access_key_id
    secret_access_key = module.manage_soc_cases_document_s3_bucket.secret_access_key
    bucket_arn        = module.manage_soc_cases_document_s3_bucket.bucket_arn
    bucket_name       = module.manage_soc_cases_document_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "manage_soc_cases_rds_to_s3_bucket" {
  metadata {
    name      = "manage-soc-cases-rds-to-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.manage_soc_cases_rds_to_s3_bucket.access_key_id
    secret_access_key = module.manage_soc_cases_rds_to_s3_bucket.secret_access_key
    bucket_arn        = module.manage_soc_cases_rds_to_s3_bucket.bucket_arn
    bucket_name       = module.manage_soc_cases_rds_to_s3_bucket.bucket_name
  }
}
