module "secrets_manager_multiple_secrets" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7" # use the latest release
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {  
    "laa-record-link-service-azure-client-id-prd" = {
      description             = "azure client id",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-record-link-service-azure-client-id-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-record-link-service-azure-client-secret-prd" = {
      description             = "azure client secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-record-link-service-azure-client-secret-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-record-link-service-azure-tenant-secret-prd" = {
      description             = "azure tenant secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-record-link-service-azure-tenant-secret-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "laa-record-link-service-base-url-prd" = {
      description             = "prd landing page base url",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-record-link-service-base-url-k8s" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "rds-postgresql-instance-output-prd" = {
      description             = "prd rds secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "rds-postgresql-instance-output" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
  }
}
