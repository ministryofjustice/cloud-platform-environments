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

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment-name
    infrastructure_support = var.infrastructure_support
  }
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
