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
    "laa-infox-db-credentials" = {
      description             = "[laa-infox-db-credentials] InfoX database credentials (URL, username, password)",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-db-credentials"
    },
    "laa-infox-keystore-password" = {
      description             = "[laa-infox-keystore-password-test] InfoX Keystore password",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-keystore-password-test"
    },
    "laa-infox-private-key-password" = {
      description             = "[laa-infox-private-key-password-test] InfoX private key password",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-private-key-password-test"
    },
    "infox-mlra-client-secret" = {
      description             = "[infox-mlra-client-secret] Client Secret used by MLRA",
      recovery_window_in_days = 7,
      k8s_secret_name         = "infox-mlra-client-secret"
    },
    "infox-nolasa-client-secret" = {
      description             = "[infox-nolasa-client-secret] Client Secret used by NoLASA",
      recovery_window_in_days = 7,
      k8s_secret_name         = "infox-nolasa-client-secret"
    },
    "infox-libra-client-secret" = {
      description             = "[infox-libra-client-secret] Client Secret used by LIBRA",
      recovery_window_in_days = 7,
      k8s_secret_name         = "infox-libra-client-secret"
    },
    "laa-infox-keystore" = {
      description             = "[laa-infox-keystore-test] JKS Keystore",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-keystore-test"
    },
    "sentry_dsn" = {
      description             = "[sentry_dsn] Sentry Data Source Name (DSN) for InfoX Test",
      recovery_window_in_days = 7,
      k8s_secret_name         = "sentry-dsn"
    },
  }
}
