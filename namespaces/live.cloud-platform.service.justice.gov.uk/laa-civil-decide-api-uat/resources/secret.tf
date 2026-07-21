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
      description             = "API key for GOV Notify",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gov-notify-api-key-uat"
    },
    "pda-authorization-token" = {
      description             = "API Key for PDA UAT environment",
      recovery_window_in_days = 7,
      k8s_secret_name         = "pda-authorization-token-uat"
    },
    "base_url_map" = {
      description             = "API Base URL Map for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "base-url-map-uat"
    },
    "allow-auto-grant" = {
      description             = "Flag for allowing autogrant within the API for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "allow-auto-grant-uat"
    },
    "auth-client-id" = {
      description             = "Entra/OAuth2 Client ID for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-id-uat"
    },
    "auth-client-secret" = {
      description             = "Entra/OAuth2 Client Secret for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-secret-uat"
    },
    "auth-scope" = {
      description             = "Entra/OAuth2 Scope for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-scope-uat"
    },
    "auth-tenant-id" = {
      description             = "Entra/OAuth2 Tenant ID for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-tenant-id-uat"
    },
    "entra-issuer-uri" = {
      description             = "Entra Issuer URI for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "entra-issuer-uri-uat"
    },
    "entra-jwk-set-uri" = {
      description             = "Entra JWK Set URI for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "entra-jwk-set-uri-uat"
    },
    "entra-aud" = {
      description             = "Entra Audience for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "entra-aud-uat"
    },
    "feature-enable-dev-token" = {
      description             = "Feature flag to enable dev token for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "feature-enable-dev-token-uat"
    },
    "feature-disable-security" = {
      description             = "Feature flag to disable security for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "feature-disable-security-uat"
    },
    "app-client-registration-id" = {
      description             = "App Client Registration ID for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "app-client-registration-id-uat"
    },
    "app-principal-name" = {
      description             = "App Principal Name for UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "app-principal-name-uat"
    },
  }
}