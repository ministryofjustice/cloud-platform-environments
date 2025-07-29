module "irsa" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name      = var.eks_cluster_name
  namespace             = var.namespace  

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name

  service_account_name = "${var.namespace}-to-mod-platform-sa"
  role_policy_arns      = {
    bedrock = aws_iam_policy.access_mod_platform_policy.arn
  }
}

data "aws_iam_policy_document" "access_mod_platform_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::891377083667:role/CicaExtractionServicesRole"
    ]
  }
}

resource "aws_iam_policy" "access_mod_platform_policy" {
  name   = "${var.namespace}-access_mod_platform_policy"
  policy = data.aws_iam_policy_document.access_mod_platform_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }

}
resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}
