locals {
  analytical_platform_roles = [
    "arn:aws:iam::593291632749:role/alpha_app_rnd_elliot_learning"
  ]
}

data "aws_iam_policy_document" "analytical_platform" {
  statement {
    sid       = "AllowAssumeRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = formatlist("%s", local.analytical_platform_roles)
  }
}

resource "aws_iam_policy" "analytical_platform_policy" {
  name        = "${var.namespace}-analytical-platform-policy"
  path        = "/"
  description = "Analytical platform policy"
  policy      = data.aws_iam_policy_document.analytical_platform.json
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "serviceaccount-${var.namespace}"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    dynamodb = aws_iam_policy.dynamodb_users_table_policy.arn
    analytical_platform = aws_iam_policy.analytical_platform_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
