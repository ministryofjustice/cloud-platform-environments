# Generate an additional IAM user to internal app
resource "random_id" "hwpv-internal-id" {
  byte_length = 16
}

resource "aws_iam_user" "hwpv-internal-user" {
  name = "hwpv-internal-user-${random_id.hwpv-internal-id.hex}"
  path = "/system/hwpv-internal-user/"
}

resource "aws_iam_access_key" "hwpv-internal-user" {
  user = aws_iam_user.hwpv-internal-user.name
}

data "aws_iam_policy_document" "hwpv-internal" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      module.hwpv_document_s3_bucket.bucket_arn,
      "${module.hwpv_document_s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "hwpv-internal-policy" {
  name   = "${var.namespace}-hwpv-internal"
  policy = data.aws_iam_policy_document.hwpv-internal.json
  user   = aws_iam_user.hwpv-internal-user.name
}

resource "kubernetes_secret" "hwpv_document_s3_bucket_internal" {
  metadata {
    name      = "hwpv-document-s3-internal"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.hwpv-internal-user.id
    secret_access_key = aws_iam_access_key.hwpv-internal-user.secret
    bucket_arn        = module.hwpv_document_s3_bucket.bucket_arn
    bucket_name       = module.hwpv_document_s3_bucket.bucket_name
  }
}
