module "s3_private_ca_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = true

  providers = {
    aws = aws.london
  }
  bucket_policy = data.aws_iam_policy_document.ca-bucket-policy.json
}

resource "aws_iam_user_policy" "dces-ca-admin_policy" {
  name   = "laa-dces-data-integration-staging-ca-admin-policy"
  policy = data.aws_iam_policy_document.dces_ca_admin_policy.json
  user   = aws_iam_user.dces_ca_admin_user_staging.name
}

resource "aws_iam_user" "dces_ca_admin_user_staging" {
  name = "laa-dces-drc-integration-staging-dces-ca-admin_user"
  path = "/system/laa-dces-data-integration-staging-dces-ca-admin_user/"

}

resource "aws_iam_access_key" "dces_ca-admin_user_staging_key" {
  user = aws_iam_user.dces_ca_admin_user_staging.name
}

data "aws_iam_policy_document" "ca-bucket-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_user.dces_ca_admin_user_staging.arn
      ]
    }
    effect  = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "$${bucket_arn}",
      "$${bucket_arn}/*"
    ]
  }
  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      "$${bucket_arn}",
      "$${bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "dces_ca_admin_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListObjectsV2",
      "s3:ListAllMyBuckets",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${module.s3_private_ca_bucket.bucket_arn}/*"
    ]
  }

}

resource "kubernetes_secret" "s3_private_ca_bucket" {
  metadata {
    name      = "private-integration-ca"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_private_ca_bucket.bucket_arn
    bucket_name = module.s3_private_ca_bucket.bucket_name
  }
}

resource "kubernetes_secret" "dces_ca_admin_user_staging" {
  metadata {
    name      = "dces-ca-admin-user-staging"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.dces_ca_admin_user_staging.arn
    access_key_id     = aws_iam_access_key.dces_ca-admin_user_staging_key.id
    secret_access_key = aws_iam_access_key.dces_ca-admin_user_staging_key.secret
  }
}
