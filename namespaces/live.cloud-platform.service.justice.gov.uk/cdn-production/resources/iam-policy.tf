data "aws_iam_policy_document" "s3_access" {
  statement {
    sid       = "BucketActions"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.s3.bucket_arn]
  }
  statement {
    sid    = "ObjectActions"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${module.s3.bucket_arn}/*", ]
  }
}

module "s3_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.55.0"

  name_prefix = "${var.namespace}-s3-access"
  path        = "/cloud-platform/"

  policy = data.aws_iam_policy_document.s3_access.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}
