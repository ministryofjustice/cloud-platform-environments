module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "sentry-dsn-url" = {
      description             = "DSN URL for Sentry Project" 
      recovery_window_in_days = 7
      k8s_secret_name         = "sentry-dsn-url"
    },
    "secret-key-base" = {
      description             = "Rails secret_key_base" 
      recovery_window_in_days = 7
      k8s_secret_name         = "secret-key-base"
    },
    "app-store-client-id" = {
      description             = "Intra ID App Registration Client ID" 
      recovery_window_in_days = 7
      k8s_secret_name         = "app-store-client-id"
    },
    "app-store-client-secret" = {
      description             = "Intra ID App Registration Client Secret" 
      recovery_window_in_days = 7
      k8s_secret_name         = "app-store-client-secret"
    },
    "azure-tenant-id" = {
      description             = "Tenant ID for Azure" 
      recovery_window_in_days = 7
      k8s_secret_name         = "azure-tenant-id"
    },
    "ga-tracking-key" = {
      description             = "Google Analytics Tracking Key" 
      recovery_window_in_days = 7
      k8s_secret_name         = "ga-tracking-key"
    },
    "notify-key" = {
      description             = "GOV UK Notify Key" 
      recovery_window_in_days = 7
      k8s_secret_name         = "notify-key"
    },
    "portal-sp-certificate-crt" = {
      description             = "SAML Service Provider Certificate for Portal" 
      recovery_window_in_days = 7
      k8s_secret_name         = "portal-sp-certificate-crt"
    },
    "portal-sp-certificate-key" = {
      description             = "SAML Service Provider Certificate Key for Portal" 
      recovery_window_in_days = 7
      k8s_secret_name         = "portal-sp-certificate-key"
    },
    "sidekiq-auth-username" = {
      description             = "Username for Sidekiq Authentication" 
      recovery_window_in_days = 7
      k8s_secret_name         = "sidekiq-auth-username"
    },
    "sidekiq-auth-password" = {
      description             = "Password for Sidekiq Authentication 
      recovery_window_in_days = 7
      k8s_secret_name         = "sidekiq-auth-password"
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