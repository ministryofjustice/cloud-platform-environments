module "reporting_hub_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  role_policy_arns = {
    data_access_policy = aws_iam_policy.reporting_hub.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "reporting_hub" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::593291632749:role/alpha_app_mbpr-test"
    ]
  }
}

resource "aws_iam_policy" "reporting_hub" {
  name   = "reporting-hub-policy-${var.environment}"
  policy = data.aws_iam_policy_document.reporting_hub.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = false
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "reporting-hub-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.reporting_hub_irsa.role_name
    rolearn        = module.reporting_hub_irsa.role_arn
    serviceaccount = module.reporting_hub_irsa.service_account.name
  }
}