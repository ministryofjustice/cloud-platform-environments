module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "gov-notify-api-key" = {
      description             = "GovNotify API key for PROD",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gov-notify-api-key-prod"
    },
     "gov-notify-template-ids" = {
      description             = "GovNotify email template IDs for PROD",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gov-notify-template-ids-prod"
    },
    "gov-notify-callback-bearer-token" = {
      description             = "GovNotify callback bearer token for PROD",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gov-notify-callback-bearer-token-prod"
    },
    "sds-config" = {
      description             = "Secrets related to Secure Document Storage",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sds-config-prod"
    },
    "entra-config" = {
      description = "API application details from Entra"
      recovery_window_in_days = 7,
      k8s_secret_name         = "entra-api-config-prod"
    }
  }
}
