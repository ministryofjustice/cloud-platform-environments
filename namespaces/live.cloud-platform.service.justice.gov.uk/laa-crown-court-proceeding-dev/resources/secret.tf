module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "maat_api_oauth_client_id" = {
      description             = "MAAT API oauth client ID for CCP Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    },
    "maat_api_oauth_client_secret" = {
      description             = "MAAT API oauth client secret for CCP Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    },
    "cda_oauth_client_id" = {
      description             = "CDA oauth client ID for CCP Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "cda-oauth-client-id"
    },
    "cda_oauth_client_secret" = {
      description             = "CDA oauth client secret for CCP Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "cda-oauth-client-secret"
    },
    "evidence_oauth_client_id" = {
      description             = "Evidence Service oauth client ID for CCP Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "evidence-oauth-client-id"
    },
    "evidence_oauth_client_secret" = {
      description             = "Evidence Service oauth client secret for CCP Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "evidence-oauth-client-secret"
    },
    "sentry_dsn" = {
      description             = "Sentry Data Source Name (DSN) for CCP Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sentry-dsn"
    },
    "prosecution_concluded_db_username" = {
      description             = "Prosecution Concluded DB Username for CCP Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sqs-prosecution-concluded-db-username"
    },
    "email_client_notify_key" = {
      description             = "Email notification client key CCP Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "email-client-notify-key"
    },
  }
}