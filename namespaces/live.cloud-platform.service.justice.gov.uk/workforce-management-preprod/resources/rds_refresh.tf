module "rds_refresh" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=6.0.2"
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name = var.eks_cluster_name

  secrets = {
    "db-refresh-secret" = {
      description = "details for preprod data refresh",
      recovery_window_in_days = 0,
      k8s_secret_name = "db-refresh-secret"
    }
  }
}