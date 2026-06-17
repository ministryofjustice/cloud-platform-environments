module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "sds-tenant-id" = {
      description             = "Entra tenant that SDS lives in",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sds-tenant-id-staging"
    },
    "sds-client-app-id" = {
      description             = "Entra application registration client id for authenticating to SDS",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sds-client-app-id-staging"
    },
    "sds-client-secret" = {
      description             = "Entra application registration client secret for authenticating to SDS",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sds-client-secret-staging"
    },
    "sds-scope" = {
      description             = "Entra scope for authenticating to an SDS service",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sds-scope-staging"
    }
  }
}
