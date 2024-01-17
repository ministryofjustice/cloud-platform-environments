resource "aws_iam_user" "internal_user_prod" {
  name = "laa-crime-equinity-historical-data-prod-internal-user"
  path = "/system/laa-crime-equinity-historical-data-prod-upload-users/"
}

resource "aws_iam_access_key" "internal_user_prod_key" {
  user = aws_iam_user.internal_user_prod.name
}

data "aws_iam_policy_document" "internal_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
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

resource "aws_iam_user_policy" "internal_policy" {
  name   = "laa-crime-equinity-historical-data-prod-internal-policy"
  policy = data.aws_iam_policy_document.internal_policy.json
  user   = aws_iam_user.internal_user_prod.name
}

resource "kubernetes_secret" "internal_user_prod" {
  metadata {
    name      = "pcms-internal-user-prod"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.internal_user_prod.arn
    access_key_id     = aws_iam_access_key.internal_user_prod_key.id
    secret_access_key = aws_iam_access_key.internal_user_prod_key.secret
  }
}
