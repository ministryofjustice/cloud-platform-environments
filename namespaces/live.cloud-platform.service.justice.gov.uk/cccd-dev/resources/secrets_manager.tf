module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "read-replica" = {
      description             = "This is the RDS read replica rds_instance_endpoint / rds-instance-endpoint",
      recovery_window_in_days = 7
      k8s_secret_name         = "rds-instance-endpoint"
    },
  }
}