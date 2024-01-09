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
    "laa-provider-details-api-secrets-dev" = {
      description             = "Db urls and credentials for laa-provider-details-api dev environment", # Required
      recovery_window_in_days = 7,                                                                      # Required
      k8s_secret_name         = "laa-provider-details-api-secrets"                                      # The name of the secret in k8s
    },
  }
}
