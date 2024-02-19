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
      description             = "MAAT API oauth client ID for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-id"
    },
    "maat_api_oauth_client_secret" = {
      description             = "MAAT API oauth client secret for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-secret"
    },
    "cma_api_oauth_client_id" = {
      description             = "CMA API oauth client ID for Validation Test",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cma-api-oauth-client-id"
    },
    "cma_api_oauth_client_secret" = {
      description             = "CMA API oauth client secret for Validation Test",
      recovery_window_in_days = 7,
      k8s_secret_name         = "cma-api-oauth-client-secret"
    },
    "ccp_api_oauth_client_id" = {
      description             = "CCP API oauth client ID for Validation Test",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ccp-api-oauth-client-id"
    },
    "ccp_api_oauth_client_secret" = {
      description             = "CCP API oauth client secret for Validation Test",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ccp-api-oauth-client-secret"
    },
    "ccc_api_oauth_client_id" = {
      description             = "CCC API oauth client ID for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "ccc-api-oauth-client-id"
    },
    "ccc_api_oauth_client_secret" = {
      description             = "CCC API oauth client secret for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "ccc-api-oauth-client-secret"
    },
    "hardship_api_oauth_client_id" = {
      description             = "Hardship API oauth client ID for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "hardship-api-oauth-client-id"
    },
    "hardship_api_oauth_client_secret" = {
      description             = "Hardship API oauth client secret for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "hardship-api-oauth-client-secret"
    },
    "orchestration_api_oauth_client_id" = {
      description             = "Orchestration API oauth client ID for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "orchestration-api-oauth-client-id"
    },
    "orchestration_api_oauth_client_secret" = {
      description             = "Orchestration API oauth client secret for Validation Test",
      recovery_window_in_days = 7
      k8s_secret_name         = "orchestration-api-oauth-client-secret"
    },
  }
}