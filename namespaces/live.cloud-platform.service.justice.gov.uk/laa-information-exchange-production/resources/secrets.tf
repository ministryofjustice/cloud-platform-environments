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
      k8s_secret_name         = "laa-infox-db-password-production"   # The name of the secret in k8s
    },
    "laa-infox-keystore-password" = {
      description             = "InfoX key store password prod",          # Required
      recovery_window_in_days = 7,                                   # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "laa-infox-keystore-password-prod"    # The name of the secret in k8s
    },
    "laa-infox-private-key-password" = {
      description             = "InfoX private key passwor prod",        # Required
      recovery_window_in_days = 7,                                   # Required - number of days that AWS Secrets Manager waits before it can delete the secret
      k8s_secret_name         = "laa-infox-private-key-prod"          # The name of the secret in k8s
    },
  }
}