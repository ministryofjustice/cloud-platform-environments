module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "sentry_dsn" = {
      description             = "Sentry Data Source Name (DSN) for Benefit checker UAT",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sentry-dsn"
    },
    "client-ids" = {
      description             = "Which client ids are valid to call the service",
      recovery_window_in_days = 7
      k8s_secret_name         = "client-ids" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "dwp-url" = {
      description             = "URL of the DWP service we are calling",
      recovery_window_in_days = 7
      k8s_secret_name         = "dwl-url" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
  }
}
