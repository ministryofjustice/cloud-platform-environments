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
    "feature_flags" = {
      description             = "[feature-flags] Feature flag env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "feature-flags"
    }
    "config-variables" = {
      description             = "[config-variables] Overridden configuration env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "config-variables"
    }
    "maat_api_oauth_client_id" = {
      description             = "[laa-dces-report-service-dev/maat-api-oauth-client-id] MAAT API OAuth2 client ID"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    }
    "maat_api_oauth_client_secret" = {
      description             = "[laa-dces-report-service-dev/maat-api-oauth-client-secret] MAAT API OAuth2 client secret"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    }
    "maat-cd-api" = {
      description             = "[maat-cd-api] MAAT court data API client credential env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-cd-api"
    }
  }
}
