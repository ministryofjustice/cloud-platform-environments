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
    "eq_archive_api_oauth_client_id" = {
      description             = "Equiniti Historical Data oauth client ID for Back-end API Integration Archive",
      recovery_window_in_days = 7
      k8s_secret_name         = "equinity-historical-data-oauth-client-id"
    },
    "eq_archive_api_oauth_client_secret" = {
      description             = "Equiniti Historical Data oauth client secret for Back-end API Integration Archive",
      recovery_window_in_days = 7
      k8s_secret_name         = "equinity-historical-data-oauth-client-secret"
    },
    "eq_archive_rds_mssql_instance_output" = {
      description             = "Equiniti Historical Data RDS secret for Back-end API Integration Archive",
      recovery_window_in_days = 7
      k8s_secret_name         = "rds-mssql-instance-output"
    },
  }
}