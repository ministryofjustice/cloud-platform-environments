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
    "datasource" = {
      description             = "[davidconneely-sandbox-dev/datasource] Database connection"
      recovery_window_in_days = 7
      k8s_secret_name         = "datasource"
    }
    "feature" = {
      description             = "[davidconneely-sandbox-dev/feature] Feature flag variables"
      recovery_window_in_days = 7
      k8s_secret_name         = "feature"
    }
    "local" = {
      description             = "[davidconneely-sandbox-dev/local] Local secrets owned by this application"
      recovery_window_in_days = 7
      k8s_secret_name         = "local"
    }
    "service1-client" = {
      description             = "[davidconneely-sandbox-dev/service1-client] Client credentials for service1"
      recovery_window_in_days = 7
      k8s_secret_name         = "service1-client"
    }
    "service2-client" = {
      description             = "[davidconneely-sandbox-dev/service2-client] Client credentials for service2"
      recovery_window_in_days = 7
      k8s_secret_name         = "service2-client"
    }
  }
}
