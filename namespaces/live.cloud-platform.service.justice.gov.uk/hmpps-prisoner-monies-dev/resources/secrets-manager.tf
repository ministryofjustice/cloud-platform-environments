
module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "emails-notify-auth-token" = {
      description             = "The API token used by the Legacy MTP project",
      recovery_window_in_days = 7,
      k8s_secret_name         = "hmpps-prisoner-monies-email-service-notify-auth-token" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },    
  }
}