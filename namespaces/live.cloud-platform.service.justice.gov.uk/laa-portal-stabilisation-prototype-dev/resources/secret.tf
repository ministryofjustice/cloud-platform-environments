module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "laa-portal-stabilisation-prototype-secret-azure-client-id-dev" = {
      description             = "azure client id",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "laa-portal-stabilisation-prototype-azure-client-id-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-portal-stabilisation-prototype-secret-azure-client-secret-dev" = {
      description             = "azure client secret",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "laa-portal-stabilisation-prototype-azure-client-secret-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-portal-stabilisation-prototype-secret-azure-tenant-secret-dev" = {
      description             = "azure tenant secret",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "laa-portal-stabilisation-prototype-azure-tenant-secret-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-portal-stabilisation-prototype-secret-gov-notify-api-key-dev" = {
      description             = "gov notification api key",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "laa-portal-stabilisation-prototype-secret-gov-notify-api-key-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
  }
}
