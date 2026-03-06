module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=v3.0.7" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "secret-1" = {
      description             = "secret-1"
      recovery_window_in_days = 7               
      k8s_secret_name         = "secret-1"
    },
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