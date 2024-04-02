resource "aws_iam_user" "upload_user_prod" {
  name = "laa-crime-equinity-historical-data-prod-upload-user"
  path = "/system/laa-crime-equinity-historical-data-prod-upload-users/"
}

resource "aws_iam_access_key" "upload_user_prod_key" {
  user = aws_iam_user.upload_user_prod.name
}

data "aws_iam_policy_document" "upload_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation"
    ]
    
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
  name   = "laa-crime-equinity-historical-data-prod-upload-policy"
  policy = data.aws_iam_policy_document.upload_policy.json
  user   = aws_iam_user.upload_user_prod.name
}

resource "kubernetes_secret" "upload_user_prod" {
  metadata {
    name      = "pcms-upload-user-prod"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.upload_user_prod.arn
    access_key_id     = aws_iam_access_key.upload_user_prod_key.id
    secret_access_key = aws_iam_access_key.upload_user_prod_key.secret
  }
}
