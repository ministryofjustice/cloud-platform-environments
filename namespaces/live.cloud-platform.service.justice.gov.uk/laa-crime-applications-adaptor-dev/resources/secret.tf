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
    "crime-apps-adaptor-alert-webhook-dev" = {
      description             = "Crime Applications Adaptor Slack Webhook",
      recovery_window_in_days = 7,
      k8s_secret_name         = "crime-apps-adaptor-alert-webhook-dev"
    },
    "maat_api_oauth_client_credentials" = {
      description             = "MAAT API oauth client id and secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-credentials"
    },
    "sentry_dsn" = {
      description             = "Sentry Data Source Name (DSN) for Crime Applications Adaptor dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sentry-dsn"
    },
    "ingress_external_allowlist_source_range" = {
      description             = "The external IP allowlist for CAA Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ingress-external-allowlist-source-range"
    },
    "ingress_internal_allowlist_source_range" = {
      description             = "The internal IP allowlist for CAA Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ingress-internal-allowlist-source-range"
    },
    "crime_apply_mock_api_auth_secret" = {
      description             = "Crime Apply Mock API auth secret for Crime Applications Adaptor dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "crime-apply-mock-api-auth-secret"
    },
  }
}