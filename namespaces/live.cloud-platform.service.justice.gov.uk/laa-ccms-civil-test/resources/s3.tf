/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_ccms_documents" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  bucket_name            = "laa-ccms-documents-${var.environment}"
}

resource "kubernetes_secret" "laa_ccms_documents" {
  metadata {
    name      = "laa-ccms-documents-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.laa_ccms_documents.bucket_arn
    bucket_name = module.laa_ccms_documents.bucket_name
  }
}

data "aws_iam_policy_document" "laa_ccms_documents_access" {
  statement {
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${module.laa_ccms_documents.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${var.namespace}-s3_policy"
  description = "Grants R/W access to specified S3 bucket"
  policy      = data.aws_iam_policy_document.laa_ccms_documents_access.json
}