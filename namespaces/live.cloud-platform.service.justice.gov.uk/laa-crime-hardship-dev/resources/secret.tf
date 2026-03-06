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
      description             = "MAAT API oauth client ID for Hardship Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    },
    "maat_api_oauth_client_secret" = {
      description             = "MAAT API oauth client secret for Hardship Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    },
    "ccc_api_oauth_client_id" = {
      description             = "CCC API oauth client ID for Hardship Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "ccc-api-oauth-client-id"
    },
    "ccc_api_oauth_client_secret" = {
      description             = "CCC API oauth client secret for Hardship Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "ccc-api-oauth-client-secret"
    },
    "cma_api_oauth_client_id" = {
      description             = "CMA API oauth client ID for Hardship Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cma-api-oauth-client-id"
    },
    "cma_api_oauth_client_secret" = {
      description             = "CMA API oauth client secret for Hardship Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cma-api-oauth-client-secret"
    },
    "sentry_dsn" = {
      description             = "Sentry Data Source Name (DSN) for Hardship Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sentry-dsn"
    },
    "ingress_internal_allowlist_source_range" = {
      description             = "Internal IP allowlist for Hardship Dev",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ingress-internal-allowlist-source-range"
    },
  }
}