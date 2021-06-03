# Generate an additional IAM user to external app
resource "random_id" "hwpv-external-id" {
  byte_length = 16
}

resource "aws_iam_user" "hwpv-external-user" {
  name = "hwpv-external-user-${random_id.hwpv-external-id.hex}"
  path = "/system/hwpv-external-user/"
}

resource "aws_iam_access_key" "hwpv-external-user" {
  user = aws_iam_user.hwpv-external-user.name
}

data "aws_iam_policy_document" "hwpv-external" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${module.hwpv_document_s3_bucket.bucket_arn}/*"
    ]
  }
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${module.hwpv_document_s3_bucket.bucket_arn}/payments/*"
    ]
  }
}

resource "aws_iam_user_policy" "hwpv-external-policy" {
  name   = "${var.namespace}-hwpv-external"
  policy = data.aws_iam_policy_document.hwpv-external.json
  user   = aws_iam_user.hwpv-external-user.name
}

resource "kubernetes_secret" "hwpv_document_s3_bucket_external" {
  metadata {
    name      = "hwpv-document-s3-external"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.hwpv-external-user.id
    secret_access_key = aws_iam_access_key.hwpv-external-user.secret
    bucket_arn        = module.hwpv_document_s3_bucket.bucket_arn
    bucket_name       = module.hwpv_document_s3_bucket.bucket_name
  }
}
