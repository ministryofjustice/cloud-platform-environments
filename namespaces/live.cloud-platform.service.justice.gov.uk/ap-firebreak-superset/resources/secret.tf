module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=2.0.0"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment            = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "azure-client-id" = {
      description             = "Client ID for Azure application connection",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-client-id"
    },
    "azure-client-secret" = {
      description             = "Client secret for Azure application connection",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-secret"
    },
    "azure-tenant-id" = {
      description             = "Azure tenant ID",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-tenant-id"
    },
    "azure-app-id" = {
      description             = "Application ID in Azure",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-app-id"
    },
  }
}
