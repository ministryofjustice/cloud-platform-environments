module "cica-test-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.email
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "cica-test-bucket" {
  metadata {
    name      = "cica-test-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.cica-test-bucket.bucket_arn
    bucket_name = module.cica-test-bucket.bucket_name
  }
}

data "aws_iam_policy_document" "cica-test-bucket-access" {
  statement {
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${module.cica-test-bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "cica-test-bucket-s3-policy" {
  name        = "${var.namespace}-s3_policy"
  description = "Grants R/W access to specified S3 bucket"
  policy      = data.aws_iam_policy_document.cica-test-bucket-access.json
}
