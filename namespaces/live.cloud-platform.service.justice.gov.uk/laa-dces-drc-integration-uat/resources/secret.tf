module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.6"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "client-ca" = {
      description             = "[client-ca] Client CA certificate file for mTLS client certificate validation"
      recovery_window_in_days = 7
      k8s_secret_name         = "client-ca"
    }
    "config-variables" = {
      description             = "[config-variables] Overridden configuration env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "config-variables"
    }
    "datasource" = {
      description             = "[datasource] Database connection env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "datasource"
    }
    "drc-client" = {
      description             = "[drc-client] Debt recovery company client credential files and env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "drc-client"
    }
    "feature-flags" = {
      description             = "[feature-flags] Feature flag env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "feature-flags"
    }
    "helm-values" = {
      description             = "[helm-values] Deployment-time secret values for Helm"
      recovery_window_in_days = 7
      k8s_secret_name         = "helm-values"
    }
    "maat-cd-api" = {
      description             = "[maat-cd-api] MAAT court data API client credential env-vars"
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-cd-api"
    }
  }
}
