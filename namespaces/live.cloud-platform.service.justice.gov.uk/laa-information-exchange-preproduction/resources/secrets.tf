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
      description             = "InfoX database credentials (URL, username, password)",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-db-credentials"
    },
    "laa-infox-keystore-password" = {
      description             = "InfoX key store password preprod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-keystore-password-preprod"
    },
    "laa-infox-private-key-password" = {
      description             = "InfoX private key password preprod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-private-key-password-preprod"
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
    },
    "laa-infox-keystore" = {
      description             = "JKS Keystore",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-infox-keystore-preprod"
    }
  }
}