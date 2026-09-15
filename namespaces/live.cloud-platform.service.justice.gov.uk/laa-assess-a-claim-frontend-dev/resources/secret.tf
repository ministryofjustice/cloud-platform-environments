module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7" # use the latest release
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "entra-secret" = {
      description             = "Auth secret for DEV",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "auth-secret-dev" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "entra-client-id" = {
      description             = "Client ID for DEV",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "client-id-dev" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "claims-api-scope" = {
      description             = "Claims API scope for DEV",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "claims-api-scope-dev" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "oidc-issuer-url" = {
      description             = "OIDC Issuer URL for DEV",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "oidc-issuer-url-dev" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
  }
}