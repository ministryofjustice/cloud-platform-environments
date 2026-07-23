module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
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
      description             = "Auth client ID from Entra for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-id-prod"
    },

    "auth-client-secret" = {
      description             = "Auth client secret from Entra for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-secret-prod"
    },

    "auth-directory-url" = {
      description             = "Auth directory URL from Entra for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-directory-url-prod"
    },

    "base_url_map" = {
      description             = "API Base URL Map for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "base-url-map-prod"
    },

    "gov-notify-api-key" = {
      description             = "API key for GOV Notify for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gov-notify-api-key-prod"
    },
    "allow-auto-grant" = {
      description             = "Flag for allowing autogrant within the API for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "allow-auto-grant-prod"
    },
    "api-entra-auth-config" = {
      description             = "API Entra Configuration for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "api-entra-auth-config-prod"
    },
    "grant_email_template_id" = {
      description             = "Template ID for sending grant emails for Production",
      recovery_window_in_days = 7,
      k8s_secret_name         = "grant-email-template-id-prod"
    },
  }
}