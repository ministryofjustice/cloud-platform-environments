module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "auth-client-id" = {
      description             = "Auth client ID from Entra for production environment",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-id-production"
    },

    "auth-client-secret" = {
      description             = "Auth client secret from Entra for production environment",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-secret-production"
    },

    "auth-directory-url" = {
      description             = "Auth directory URL from Entra for production environment",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-directory-url-production"
    },

    "base_url_map" = {
      description             = "API Base URL Map for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "base-url-map-production"
    },

    "gov-notify-api-key" = {
      description             = "API key for GOV Notify",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gov-notify-api-key-prod"
    },
  }
}