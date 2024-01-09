module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.0"
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
      k8s_secret_name         = "laa-maat-db-password-preprod"           # The name of the secret in k8s. Note that in LZ, Preprod = Staging.
    },
  }
}
