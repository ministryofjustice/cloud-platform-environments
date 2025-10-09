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
    "laa-amend-a-claim-azure-client-id-dev" = {
      description             = "Azure client id",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-azure-client-id" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-azure-client-secret-dev" = {
      description             = "Azure client secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-azure-client-secret" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-azure-tenant-secret-dev" = {
      description             = "Azure tenant secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-azure-tenant" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-base-url-dev" = {
      description             = "Dev landing page base url",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-base-url" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-sentry-dsn-dev" = {
      description             = "Dev sentry dsn",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-sentry-dsn" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-claims-api-url" = {
      description             = "Claims Api Url",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-claims-api-url" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-amend-a-claim-claims-api-token" = {
      description             = "Claims Api Token",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-amend-a-claim-claims-api-token" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    }
  }
}
