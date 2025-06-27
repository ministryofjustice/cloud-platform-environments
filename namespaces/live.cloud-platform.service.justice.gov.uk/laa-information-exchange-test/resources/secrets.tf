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
    "laa-infox-db-credentials" = {
      description             = "InfoX Soap database credentials (URL, username, password)",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-db-credentials"
    },
    "laa-infox-mtls-certs" = {
      description             = "InfoX MTLS Certificates (base64-encoded). These certificates are used to secure the Libra endpoint.",
      recovery_window_in_days = 7,
      k8s_secret_name         = "app-libra-mtls-certs"
    },
    "laa-infox-keystore-password" = {
      description             = "InfoX Keystore password [test].",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-keystore-password-test"
    },
    "laa-infox-private-key-password" = {
      description             = "InfoX private key password [test].",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-private-key-password-test"
    },
    "infox-mlra-client-secret" = {
      description             = "Client Secret used by MLRA",
      recovery_window_in_days = 7,
      k8s_secret_name         = "infox-mlra-client-secret"
    },
    "infox-nolasa-client-secret" = {
      description             = "Client Secret used by NoLASA",
      recovery_window_in_days = 7,
      k8s_secret_name         = "infox-nolasa-client-secret"
    },
    "infox-libra-client-secret" = {
      description             = "Client Secret used by LIBRA",
      recovery_window_in_days = 7,
      k8s_secret_name         = "infox-libra-client-secret"
    }
  }
}
