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
    "laa-infox-db-password" = {
      description             = "InfoX Soap user database password", # Required
      recovery_window_in_days = 7,                                   # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "laa-infox-db-password-test"         # The name of the secret in k8s
    },
    "laa-infox-mtls-certs" = {
      description             = "InfoX MTLS Certificates (base64-encoded). These certificates are used to secure the Libra endpoint.", # Required
      recovery_window_in_days = 7,                                                                                                     # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "app-libra-mtls-certs"                                                                                 # The name of the secret in k8s
    },
    "laa-infox-keystore-password" = {
      description             = "InfoX Keystore password [test].",   # Required
      recovery_window_in_days = 7,                            # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "app-infox-keystore-password" # The name of the secret in k8s
    },
    "laa-infox-private-key" = {
      description             = "InfoX private key [test].",   # Required
      recovery_window_in_days = 7,                      # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "app-infox-private-key" # The name of the secret in k8s
    },
    "laa-infox-private-key-password" = {
      description             = "InfoX private key password [test].",   # Required
      recovery_window_in_days = 7,                      # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "app-infox-private-key-password" # The name of the secret in k8s
    },
    "laa-infox-pkcs12-password" = {
      description             = "InfoX private pkcs12 password [test].",   # Required
      recovery_window_in_days = 7,                      # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "app-infox-pkcs12-password" # The name of the secret in k8s
    },
  }
}
