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
      description             = "Auth client ID from Entra for Prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-id-production"
    },

    "auth-client-secret" = {
      description             = "Auth client secret from Entra for Prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-client-secret-production"
    },

    "auth-directory-url" = {
      description             = "Auth directory URL from Entra for Prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "auth-directory-url-production"
    },

    "base_url_map" = {
      description             = "API Base URL Map for Prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "base-url-map-production"
    },

    "data_store_auth_scope" = {
      description             = "Auth scope for integration with Data Store for Prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "data-store-auth-scope-production"
    },

    "decide_api_auth_scope" = {
      description             = "Auth scope for integration with Civil Decide API for Prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "decide-api-auth-scope-production"
    },

    "refuse_email_template_id" = {
      description             = "Refuse Decision Template ID for Prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "refuse-email-template-id-production"
    },
  }
}
