data "aws_iam_policy_document" "s3_irsa" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [module.s3_test_oidc.bucket_arn]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["${module.s3_test_oidc.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_irsa" {
  name   = "${var.namespace}-s3-irsa"
  policy = data.aws_iam_policy_document.s3_irsa.json
}

module "s3_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.kubernetes_cluster
  service_account_name = "${var.namespace}-s3"
  namespace            = var.namespace
  role_policy_arns = {
    s3 = aws_iam_policy.s3_irsa.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
