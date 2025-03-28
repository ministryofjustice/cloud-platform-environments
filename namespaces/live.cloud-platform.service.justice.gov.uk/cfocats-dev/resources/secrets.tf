module "secrets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  secrets = {
    "gov-uk-notify-key": {
        description             = "GOV.UK Notify Key"
        recovery_window_in_days = 7
        k8s_secret_name         = "gov-uk-notify-key"
    },
    "sentry-dsn": {
        description             = "Sentry DSN"
        recovery_window_in_days = 7
        k8s_secret_name         = "sentry-dsn"
    },
    "ordnance-api-url": {
        description             = "Ordnance API URL"
        recovery_window_in_days = 7
        k8s_secret_name         = "ordnance-api-url"
    },
    "ordnance-api-key": {
        description             = "Ordnance API Key"
        recovery_window_in_days = 7
        k8s_secret_name         = "ordnance-api-key"
    },
    "dms-api-url": {
        description             = "DMS API URL"
        recovery_window_in_days = 7
        k8s_secret_name         = "dms-api-url"
    },
    "dms-api-key": {
        description             = "DMS API Key"
        recovery_window_in_days = 7
        k8s_secret_name         = "dms-api-key"
    }
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}