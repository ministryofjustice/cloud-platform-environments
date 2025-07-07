/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_ccms_pui_docs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  bucket_name            = "laa-ccms-pui-docs-${var.environment}"

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-56d"
      prefix                                 = "56d/"
      abort_incomplete_multipart_upload_days = 56
      expiration = [
        {
          days = 56
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 56
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "laa_ccms_pui_docs" {
  metadata {
    name      = "laa-ccms-pui-docs-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.laa_ccms_pui_docs.bucket_arn
    bucket_name = module.laa_ccms_pui_docs.bucket_name
  }
}

data "aws_iam_policy_document" "laa_ccms_pui_docs_access" {
  statement {
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${module.laa_ccms_pui_docs.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${var.namespace}-s3_policy"
  description = "Grants R/W access to specified S3 bucket"
  policy      = data.aws_iam_policy_document.laa_ccms_pui_docs_access.json
}
