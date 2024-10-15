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
    "drc-client-auth-tls" = {
      description             = "DRC mTLS client credentials [laa-dces-drc-integration-uat]"
      recovery_window_in_days = 7
      k8s_secret_name         = "drc-client-auth-tls"
    },
    "ca-crt" = {
      description             = "ca.crt for mTLS client certificate validation [laa-dces-drc-integration-uat]"
      recovery_window_in_days = 7
      k8s_secret_name         = "ca-crt"
    },
    "feature" = {
      description             = "Feature flag variables [laa-dces-drc-integration-uat]"
      recovery_window_in_days = 7
      k8s_secret_name         = "feature"
    }
    "maat_api_oauth_client_id" = {
      description             = "MAAT API OAuth2 client ID [laa-dces-drc-integration-uat]"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    },
    "maat_api_oauth_client_secret" = {
      description             = "MAAT API OAuth2 client secret [laa-dces-drc-integration-uat]"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    }
  }
}
