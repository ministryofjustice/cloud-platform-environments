module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  eks_cluster_name = var.eks_cluster_name

  secrets = {
    "cloud-platform-go-get-module-private-key" = {
      description             = "GitHub App private key for cloud-platform-go-get-module"
      recovery_window_in_days = 7
      k8s_secret_name         = "cloud-platform-go-get-module-private-key"
    }
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}