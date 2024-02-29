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
    "azure_app_client_id" = {
      description             = "App (client) ID for Azure app connection, app",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-app-client-id"
    },
    "azure_openapi_client_id" = {
      description             = "App (client) ID for Azure app connection, OpenAPI",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-openapi-client-id"
    },
    "azure_tenant_id" = {
      description             = "Azure directory (tenant) ID",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-tenant-id"
    },
  }
}
