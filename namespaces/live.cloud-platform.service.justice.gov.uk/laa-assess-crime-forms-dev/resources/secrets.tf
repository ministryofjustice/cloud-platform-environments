module "secrets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "sentry-dsn" = {
      description             = "DSN URL for Sentry Project" 
      recovery_window_in_days = 7
      k8s_secret_name         = "sentry-dsn"
    },
    "app-secrets" = {
      description             = "Rails app secrets" 
      recovery_window_in_days = 7
      k8s_secret_name         = "app-secrets"
    },
    "app-store-auth" = {
      description             = "App Store Azure Authentication Details" 
      recovery_window_in_days = 7
      k8s_secret_name         = "app-store-auth"
    },
    "google-analytics" = {
      description             = "Google Analytics Secrets" 
      recovery_window_in_days = 7
      k8s_secret_name         = "google-analytics"
    },
    "notify-key" = {
      description             = "GOV UK Notify Key" 
      recovery_window_in_days = 7
      k8s_secret_name         = "notify-key"
    },
    "sidekiq-auth" = {
      description             = "Credentials for Sidekiq Page" 
      recovery_window_in_days = 7
      k8s_secret_name         = "sidekiq-auth"
    },
    "azure-auth" = {
      description             = "Client ID for Intra (FKA Azure AD) ID Login"
      recovery_window_in_days = 7
      k8s_secret_name         = "azure-auth"
    },
    "ordnance-survey" = {
      description             = "Credentials to access the Ordnance Survey API"
      recovery_window_in_days = 7
      k8s_secret_name         = "ordnance-survey"
    }
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
