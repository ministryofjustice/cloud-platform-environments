resource "aws_iam_user" "upload_user_uat" {
  name = "laa-crime-equinity-historical-data-uat-upload-user"
  path = "/system/laa-crime-equinity-historical-data-uat-upload-users/"
}

resource "aws_iam_access_key" "upload_user_uat_key" {
  user = aws_iam_user.upload_user_uat.name
}

data "aws_iam_policy_document" "upload_policy" {
  statement {
    actions = ["s3:PutObject", "s3:GetObject", "s3:ListObjects"]
    
    resources = [
      "${module.s3_bucket.bucket_arn}/*"
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
  name   = "laa-crime-equinity-historical-data-uat-upload-policy"
  policy = data.aws_iam_policy_document.upload_policy.json
  user   = aws_iam_user.upload_user_uat.name
}

resource "kubernetes_secret" "upload_user_uat" {
  metadata {
    name      = "pcms-upload-user-uat"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.upload_user_uat.arn
    access_key_id     = aws_iam_access_key.upload_user_uat_key.id
    secret_access_key = aws_iam_access_key.upload_user_uat_key.secret
  }
}