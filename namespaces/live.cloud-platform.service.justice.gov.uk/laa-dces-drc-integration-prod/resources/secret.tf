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
    "dces-drc-integration-service-alert-webhook-test" = {
      description             = "[dces-drc-integration-service-alert-webhook-prod] Slack webhook"
      recovery_window_in_days = 7
      k8s_secret_name         = "dces-drc-integration-service-alert-webhook-prod"
    },
    "drc-client-auth-tls" = {
      description             = "DRC mTLS client credentials [laa-dces-drc-integration-prod]"
      recovery_window_in_days = 7
      k8s_secret_name         = "drc-client-auth-tls"
    },
    "ca-crt" = {
      description             = "[laa-dces-drc-integration-prod/ca-crt] ca.crt for mTLS client certificate validation"
      recovery_window_in_days = 7
      k8s_secret_name         = "ca-crt"
    }
    "dces-datasource" = {
      description             = "[laa-dces-drc-integration-prod/dces-datasource] Database connection"
      recovery_window_in_days = 7
      k8s_secret_name         = "dces-datasource"
    }
    "drc-client-auth-tls" = {
      description             = "[laa-dces-drc-integration-prod/drc-client-auth-tls] DRC mTLS client credentials"
      recovery_window_in_days = 7
      k8s_secret_name         = "drc-client-auth-tls"
    }
    "feature" = {
      description             = "[laa-dces-drc-integration-prod/feature] Feature flag variables"
      recovery_window_in_days = 7
      k8s_secret_name         = "feature"
    }
    "maat_api_oauth_client_id" = {
      description             = "[laa-dces-drc-integration-prod/maat-api-oath-client-id] MAAT API OAuth2 client ID"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    }
    "maat_api_oauth_client_secret" = {
      description             = "[laa-dces-drc-integration-prod/maat-api-oauth-client-secret] MAAT API OAuth2 client secret"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    }
    "config-variables" = {
      description             = "[config-variables] Overridden configuration env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "config-variables"
    }
    "client-ca" = {
      description             = "[client-ca] Client CA certificate file for mTLS client certificate validation"
      recovery_window_in_days = 7
      k8s_secret_name         = "client-ca"
    }
    "datasource" = {
      description             = "[datasource] Database connection env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "datasource"
    }
    "drc-client" = {
      description             = "[drc-client] Debt recovery company client credential files and env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "drc-client"
    }
    "feature-flags" = {
      description             = "[feature-flags] Feature flag env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "feature-flags"
    }
    "maat-cd-api" = {
      description             = "[maat-cd-api] MAAT court data API client credential env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-cd-api"
    }
  }
}
