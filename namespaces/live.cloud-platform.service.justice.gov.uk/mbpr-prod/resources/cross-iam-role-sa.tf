module "mbpr_prod_irsa" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  namespace             = var.namespace
  service_account_name  = "mbpr-prod-cp-data-access"
  role_policy_arns = {
    data_access_policy = aws_iam_policy.mbpr_prod.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = false
  environment_name       = var.environment
  team_name              = var.team_name
  infrastructure_support = "missionbrilliantperformancereportingteam@justice.gov.uk"
}

data "aws_iam_policy_document" "mbpr_prod" {
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

resource "aws_iam_policy" "mbpr_prod" {
  name   = "mbpr-prod"
  policy = data.aws_iam_policy_document.mbpr_prod.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = false
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = "missionbrilliantperformancereportingteam@justice.gov.uk"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "mbpr-prod-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.mbpr_prod_irsa.role_name
    rolearn        = module.mbpr_prod_irsa.role_arn
    serviceaccount = module.mbpr_prod_irsa.service_account.name
  }
}