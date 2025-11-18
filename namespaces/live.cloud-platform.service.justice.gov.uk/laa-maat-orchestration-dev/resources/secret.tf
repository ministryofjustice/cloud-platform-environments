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
      description             = "MAAT API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    },
    "maat_api_oauth_client_secret" = {
      description             = "MAAT API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    },
    "cma_api_oauth_client_id" = {
      description             = "CMA API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cma-api-oauth-client-id"
    },
    "cma_api_oauth_client_secret" = {
      description             = "CMA API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cma-api-oauth-client-secret"
    },
    "ccp_api_oauth_client_id" = {
      description             = "CCP API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ccp-api-oauth-client-id"
    },
    "ccp_api_oauth_client_secret" = {
      description             = "CCP API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ccp-api-oauth-client-secret"
    },
    "ccc_api_oauth_client_id" = {
      description             = "CCC API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ccc-api-oauth-client-id"
    },
    "ccc_api_oauth_client_secret" = {
      description             = "CCC API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ccc-api-oauth-client-secret"
    },
    "hardship_api_oauth_client_id" = {
      description             = "Hardship API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "hardship-api-oauth-client-id"
    },
    "hardship_api_oauth_client_secret" = {
      description             = "Hardship API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "hardship-api-oauth-client-secret"
    },
    "cat_api_oauth_client_id" = {
      description             = "CAT API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cat-api-oauth-client-id"
    },
    "cat_api_oauth_client_secret" = {
      description             = "CAT API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cat-api-oauth-client-secret"
    },
    "evidence_api_oauth_client_id" = {
      description             = "Evidence API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "evidence-api-oauth-client-id"
    },
    "evidence_api_oauth_client_secret" = {
      description             = "Evidence API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "evidence-api-oauth-client-secret"
    },
    "validation_api_oauth_client_id" = {
      description             = "Validation API oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "validation-api-oauth-client-id"
    },
    "validation_api_oauth_client_secret" = {
      description             = "Validation API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "validation-api-oauth-client-secret"
    },
    "cas_api_oauth_client_id" = {
      description             = "Crime Assessment Service oauth client ID for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cas-api-oauth-client-id"
    },
    "cas_api_oauth_client_secret" = {
      description             = "Crime Assessment Service API oauth client secret for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cas-api-oauth-client-secret"
    },
    "ingress_external_allowlist_source_range" = {
      description             = "The external IP allowlist for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ingress-external-allowlist-source-range"
    },
    "ingress_internal_allowlist_source_range" = {
      description             = "The internal IP allowlist for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ingress-internal-allowlist-source-range"
    },
    "sentry_dsn" = {
      description             = "Sentry Data Source Name (DSN) for Orchestration Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sentry-dsn"
    },
  }
}