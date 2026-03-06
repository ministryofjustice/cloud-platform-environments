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
    "laa_maat_db_password" = {
      description             = "Password for accessing MAAT DB in LAA", # Required
      recovery_window_in_days = 7,                                       # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "laa-maat-db-password-dev"               # The name of the secret in k8s
    },
    "nolasa-infox-client-secret" = {
      description             = "Client Secret used in communications with InfoX", # Required
      recovery_window_in_days = 7,                                       # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "nolasa-infox-client-secret"               # The name of the secret in k8s
    },
    "datasource-credentials" = {
      description             = "Dev data source credentials",
      recovery_window_in_days = 7
      k8s_secret_name         = "datasource-credentials"
     },
     "sentry_dsn" = {
       description             = "Sentry Data Source Name (DSN) for Nolasa Dev",
       recovery_window_in_days = 7,
       k8s_secret_name         = "sentry-dsn"
     }
  }
}
