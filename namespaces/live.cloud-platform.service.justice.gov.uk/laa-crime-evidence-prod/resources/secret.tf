module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.6"
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
      description             = "MAAT API oauth client ID for Evidence Prod",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    },
    "maat_api_oauth_client_secret" = {
      description             = "MAAT API oauth client secret for Evidence Prod",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    },
    "crime_evidence_alert_webhook_prod" = {
      description             = "Crime Evidence Slack Webhook",
      recovery_window_in_days = 7,
      k8s_secret_name         = "crime-evidence-alert-webhook-prod"
    },
    "sentry_dsn" = {
      description             = "Sentry Data Source Name (DSN) for Crime Evidence prod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sentry-dsn"
    },
  }
}