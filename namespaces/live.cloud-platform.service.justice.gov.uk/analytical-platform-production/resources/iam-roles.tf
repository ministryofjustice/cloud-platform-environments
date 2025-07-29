module "grafana_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "grafana-irsa"
  role_policy_arns = {
    irsa = module.grafana_irsa_iam_policy.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "grafana_irsa" {
  metadata {
    namespace = var.namespace
    name      = "grafana-irsa"
  }

  data = {
    role_arn = module.grafana_irsa.role_arn
  }
}
