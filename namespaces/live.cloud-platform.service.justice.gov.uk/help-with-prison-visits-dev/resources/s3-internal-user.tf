# Define policy for internal app to access S3
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

resource "aws_iam_policy" "hwpv-internal" {
  name   = "${var.namespace}-hwpv-internal"
  path   = "/"
  policy = data.aws_iam_policy_document.hwpv-internal.json
}

resource "kubernetes_secret" "hwpv_document_s3_bucket_internal" {
  metadata {
    name      = "hwpv-document-s3-internal"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hwpv_document_s3_bucket.bucket_arn
    bucket_name = module.hwpv_document_s3_bucket.bucket_name
  }
}
