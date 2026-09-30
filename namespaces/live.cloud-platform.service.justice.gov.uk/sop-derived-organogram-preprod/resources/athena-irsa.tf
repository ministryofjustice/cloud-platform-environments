data "aws_iam_policy_document" "athena_assume_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::593291632749:role/alpha_app_sop-derived-organogram"]
  }
}

resource "aws_iam_policy" "athena_assume_role" {
  name        = "${var.namespace}-athena-assume-role"
  description = "Allows the Athena ServiceAccount to assume the Analytical Platform role"
  policy      = data.aws_iam_policy_document.athena_assume_role.json
}

module "athena_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "athena-serviceaccount"
  role_policy_arns = {
    athena = aws_iam_policy.athena_assume_role.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}