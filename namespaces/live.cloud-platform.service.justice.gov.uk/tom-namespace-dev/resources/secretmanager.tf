module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.2"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "hello-world-app" = {
      description             = "Test secret for hello world",
      recovery_window_in_days = 15
      k8s_secret_name         = "hello-world-secret"
      k8s_secret_key          = "POSTGRES_URL"
    },

    "multicontainer-app" = {
      description             = "Test secret for Multi container app",
      recovery_window_in_days = 15
      k8s_secret_name         = "multi-container-secret"
      k8s_secret_key          = "MONDG_DB_URL"
    },
    "reference-app" = {
      description             = "Test secret for Multi container app",
      recovery_window_in_days = 7
      k8s_secret_name         = "reference-app-secret"
      k8s_secret_key          = "MONDG_DB_URL"
    },
  }
}
