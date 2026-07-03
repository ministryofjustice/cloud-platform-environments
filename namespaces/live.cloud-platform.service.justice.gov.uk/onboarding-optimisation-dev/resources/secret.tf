module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  environment_name       = var.environment
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  infrastructure_support = var.infrastructure_support

  secrets = {
    "hmpps_api_credentials" = {
      description             = "HMPPS Integration API credentials and certificates for onboarding-optimisation dev"
      recovery_window_in_days = 0
      k8s_secret_name         = "hmpps-api-credentials"
    }
  }
}
