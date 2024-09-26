
resource "aws_iam_user" "advantis_upload_user_dev" {
  name = "laa-dces-drc-integration-dev-advantis-upload-user"
  path = "/system/laa-dces-data-integration-dev-advantis-upload-users/"
}

resource "aws_iam_access_key" "advantis_upload_user_dev_key" {
  user = aws_iam_user.advantis_upload_user_dev.name
}

data "aws_iam_policy_document" "upload_policy" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListObjectsV2",
      "s3:ListAllMyBuckets",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${module.s3_advantis_bucket.bucket_arn}/DRC/*"
    ]
  }


  statement {
    effect = "Deny"
    actions = ["s3:*"]
    resources = [
      module.s3_advantis_bucket.bucket_arn,
      "${module.s3_advantis_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "upload_policy" {
  name   = "laa-dces-data-integration-dev-advantis-upload-policy"
  policy = data.aws_iam_policy_document.upload_policy.json
  user   = aws_iam_user.advantis_upload_user_dev.name
}

resource "kubernetes_secret" "advantis_upload_user_dev" {
  metadata {
    name      = "advantis-upload-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.advantis_upload_user_dev.arn
    access_key_id     = aws_iam_access_key.advantis_upload_user_dev_key.id
    secret_access_key = aws_iam_access_key.advantis_upload_user_dev_key.secret
  }
}

resource "aws_iam_user" "admin_advantis_user_dev" {
  name = "laa-dces-data-integration-dev-admin-advantis-user"
  path = "/system/laa-dces-data-integration-dev-admin-advantis-users/"
}

resource "aws_iam_access_key" "admin_user_dev_key" {
  user = aws_iam_user.admin_advantis_user_dev.name
}

data "aws_iam_policy_document" "admin_policy" {
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
      "${module.s3_advantis_bucket.bucket_arn}/*"
    ]
  }

  statement {
    effect = "Deny"
    actions = ["s3:*"]
    resources = [
      module.s3_advantis_bucket.bucket_arn,
      "${module.s3_advantis_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}


resource "aws_iam_user_policy" "admin_policy" {
  name   = "laa-dces-data-integration-dev-admin-advantis-policy"
  policy = data.aws_iam_policy_document.admin_policy.json
  user   = aws_iam_user.admin_advantis_user_dev.name
}

resource "kubernetes_secret" "admin-advantis-user_dev" {
  metadata {
    name      = "admin-advantis-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.admin_advantis_user_dev.arn
    access_key_id     = aws_iam_access_key.admin_user_dev_key.id
    secret_access_key = aws_iam_access_key.admin_user_dev_key.secret
  }
}