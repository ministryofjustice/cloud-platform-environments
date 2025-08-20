# Define policy for external app to access S3
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

resource "aws_iam_policy" "hwpv-external" {
  name   = "${var.namespace}-hwpv-external"
  path   = "/"
  policy = data.aws_iam_policy_document.hwpv-external.json

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

resource "kubernetes_secret" "hwpv_document_s3_bucket_external" {
  metadata {
    name      = "hwpv-document-s3-external"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hwpv_document_s3_bucket.bucket_arn
    bucket_name = module.hwpv_document_s3_bucket.bucket_name
  }
}
