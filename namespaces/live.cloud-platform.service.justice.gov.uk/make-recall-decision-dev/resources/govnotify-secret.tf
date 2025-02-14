module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "govnotify-webapp-pwd" = {
      description             = "Password for logging in to the GovNotify management web app",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "govnotify-webapp-pwd" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "govnotify-teamandguest-api-id" = {
      description             = "GovNotify API Key",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "govnotify-teamandguest-api-id" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "govnotify-teamandguest-api-secret" = {
      description             = "GovNotify API secret",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "govnotify-teamandguest-api-secret" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
  }
}
