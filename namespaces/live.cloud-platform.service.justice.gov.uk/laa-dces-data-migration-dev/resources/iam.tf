resource "aws_iam_user" "upload_user_dev" {
  name = "laa-dces-data-migration-dev-upload-user"
  path = "/system/laa-dces-data-migration-dev-upload-users/"
}

resource "aws_iam_access_key" "upload_user_dev_key" {
  user = aws_iam_user.upload_user_dev.name
}

data "aws_iam_policy_document" "upload_policy" {

  statement {
    effect = "Deny"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${module.s3_bucket.bucket_arn}/"
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["hello/*"]
    }

  }


  statement {
    actions = [
      "s3:PutObject",
      /*"s3:DeleteObject",
      "s3:GetObject",*/
      "s3:GetBucketLocation",
      "s3:ListBucket",
      /*"s3:ListObjectsV2",*/
      /*"s3:ListAllMyBuckets",*/
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:GetObject"/*,
      "s3:GetObjectAcl"*/
    ]
    
    resources = [
      "${module.s3_bucket.bucket_arn}/drc/*"
    ]
  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "upload_policy" {
  name   = "laa-dces-data-migration-dev-upload-policy"
  policy = data.aws_iam_policy_document.upload_policy.json
  user   = aws_iam_user.upload_user_dev.name
}

resource "kubernetes_secret" "upload_user_dev" {
  metadata {
    name      = "dces-upload-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.upload_user_dev.arn
    access_key_id     = aws_iam_access_key.upload_user_dev_key.id
    secret_access_key = aws_iam_access_key.upload_user_dev_key.secret
  }
}
