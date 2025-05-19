data "aws_iam_policy_document" "grafana_irsa" {
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      for account in local.analytical_platform_accounts : "arn:aws:iam::${account}:role/${local.analytical_platform_observability_role_name}"
    ]
  }
}

module "grafana_irsa_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.54.1"

  name_prefix = "${var.namespace}-grafana-irsa"
  path        = "/cloud-platform/"

  policy = data.aws_iam_policy_document.grafana_irsa.json

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
