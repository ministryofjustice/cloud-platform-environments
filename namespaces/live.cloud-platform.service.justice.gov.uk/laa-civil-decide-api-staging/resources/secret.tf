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
    "gov-notify-api-key" = {
      description             = "API key for GOV Notify for Staging",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gov-notify-api-key-staging"
    },
    "pda-authorization-token" = {
      description             = "API Key for PDA Staging/PreProd environment",
      recovery_window_in_days = 7,
      k8s_secret_name         = "pda-authorization-token-staging"
    },
    "base_url_map" = {
      description             = "API Base URL Map for Staging",
      recovery_window_in_days = 7,
      k8s_secret_name         = "base-url-map-staging"
    },
    "allow-auto-grant" = {
      description             = "Flag for allowing autogrant within the API for Staging",
      recovery_window_in_days = 7,
      k8s_secret_name         = "allow-auto-grant-staging"
    },
    "api-entra-auth-config" = {
      description             = "API Entra Configuration for Staging",
      recovery_window_in_days = 7,
      k8s_secret_name         = "api-entra-auth-config-staging"
    },
    "grant_email_template_id" = {
      description             = "Template ID for sending grant emails for Staging",
      recovery_window_in_days = 7,
      k8s_secret_name         = "grant-email-template-id-staging"
    },
  }
}