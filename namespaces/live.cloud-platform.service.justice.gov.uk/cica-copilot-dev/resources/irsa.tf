module "mod_bedrock_irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = {
    bedrock = aws_iam_policy.access_bedrock_service.arn
  }
  service_account_name = "${var.namespace}-to-mod-platform-bedrock-sa"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsadcs" {
  metadata {
    name      = "irsa-guidanceoutput"
    namespace = var.namespace
  }
  data = {
    role           = module.mod_bedrock_irsa.role_name
    serviceaccount = module.mod_bedrock_irsa.service_account.name
    rolearn        = module.mod_bedrock_irsa.role_arn
  }
}