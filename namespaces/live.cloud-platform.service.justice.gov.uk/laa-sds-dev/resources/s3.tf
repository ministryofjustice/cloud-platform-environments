/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}


resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "laa-sds-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

data "aws_iam_policy_document" "laa-sds-access" {
  statement {
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${module.s3_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${var.namespace}-s3_policy"
  description = "Grants R/W access to specified S3 bucket"
  policy      = data.aws_iam_policy_document.laa-sds-access.json
}
