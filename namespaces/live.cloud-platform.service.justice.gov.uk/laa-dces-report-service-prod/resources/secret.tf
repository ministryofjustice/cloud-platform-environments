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
    "dces-report-service-alert-webhook-prod" = {
      description             = "[laa-dces-report-service-prod/dces-report-service-alert-webhook-prod] Slack webhook"
      recovery_window_in_days = 7
      k8s_secret_name         = "dces-report-service-alert-webhook-prod"
    }
    "feature_flags" = {
      description             = "[laa-dces-report-service-prod/feature-flags] Feature flag variables"
      recovery_window_in_days = 7
      k8s_secret_name         = "feature-flags"
    }
    "maat_api_oauth_client_id" = {
      description             = "[laa-dces-report-service-prod/maat-api-oauth-client-id] MAAT API OAuth2 client ID"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    }
    "maat_api_oauth_client_secret" = {
      description             = "[laa-dces-report-service-prod/maat-api-oauth-client-secret] MAAT API OAuth2 client secret"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    }
  }
}
