module "secrets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "sentry" = {
      description             = "sentry"
      recovery_window_in_days = 7
      k8s_secret_name         = "sentry"
    },
    "azure-secret" = {
      description             = "azure-secret"
      recovery_window_in_days = 7
      k8s_secret_name         = "azure-secret"
    },
    "sidekiq-auth" = {
      description             = "sidekiq-auth"
      recovery_window_in_days = 7
      k8s_secret_name         = "sidekiq-auth"
    },
    "app-secrets" = {
      description             = "app-secrets"
      recovery_window_in_days = 7
      k8s_secret_name         = "app-secrets"
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
