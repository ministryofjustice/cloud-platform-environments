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
    "laa-amend-a-claim-azure-client-id-production" = {
      description             = "Production Azure client id",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-azure-client-id" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-azure-client-secret-production" = {
      description             = "Production Azure client secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-azure-client-secret" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-azure-tenant-secret-production" = {
      description             = "Production Azure tenant secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-azure-tenant" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-base-url-production" = {
      description             = "Production landing page base url",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-base-url" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-sentry-dsn-production" = {
      description             = "Production sentry dsn",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-sentry-dsn" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-claims-api-url-production" = {
      description             = "Production Claims Api Url",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-claims-api-url" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-claims-api-token-production" = {
      description             = "Production Claims Api Token",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-claims-api-token" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-provider-api-url-production" = {
      description             = "Production Provider Api Url",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-provider-api-url"
    },
    "laa-amend-a-claim-provider-api-token-production" = {
      description             = "Production Provider Api Token",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-provider-api-token"
    }
  }
}
