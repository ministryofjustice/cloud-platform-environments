module "mbpr_test_irsa" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name      = var.eks_cluster_name
  namespace             = var.namespace
  service_account_name  = "mbpr-test-cp-data-access"
  role_policy_arns = {
    quicksight = aws_iam_policy.mbpr_test.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = false
  environment_name       = var.environment
  team_name              = var.team_name
  infrastructure_support = "missionbrilliantperformancereportingteam@justice.gov.uk"
}

data "aws_iam_policy_document" "mbpr_test" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::992382429243:role/mbpr-test-ap-data-access"
    ]
  }
}

resource "aws_iam_policy" "mbpr_test" {
  name   = "mbpr-test"
  policy = data.aws_iam_policy_document.mbpr_test.json

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
    name      = "mbpr-test-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.mbpr_test_irsa.role_name
    rolearn        = module.mbpr_test_irsa.role_arn
    serviceaccount = module.mbpr_test_irsa.service_account.name
  }
}