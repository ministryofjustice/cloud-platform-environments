module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  kubernetes_cluster     = var.kubernetes_cluster


  secrets = {
    "srrc-verify-biometric-scans-api-auth" = {
      description             = "Authentication secrets for SRRC verify biometric scans API"
      recovery_window_in_days = 7
      k8s_secret_name         = "srrc-verify-biometric-scans-api-auth"
    }
  }
}