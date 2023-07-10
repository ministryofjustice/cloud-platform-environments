module "secrets_manager" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=2.0.0"
  team_name               = var.team_name
  application             = var.application
  business_unit           = var.business_unit
  is_production           = var.is_production
  namespace               = var.namespace
  environment             = var.environment
  infrastructure_support  = var.infrastructure_support
  eks_cluster_name        = var.eks_cluster_name

  secrets = {
    "azure/appId" = {

      description             = "The Id for the App registration on Azure", // Required
      recovery_window_in_days = 7, // Required
      k8s_secret_name        = "azure/appId" // The name of the secret in k8s
    },
  }
}
