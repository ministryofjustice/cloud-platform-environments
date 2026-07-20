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
    "slack-webhook-url" = {
      description             = "Slack webhook URL for non-production environment",
      recovery_window_in_days = 7,
      k8s_secret_name         = "slack-webhook-url-alerts-non-prod"
    },
    
    "azure-entra-api-client-secret" = {
      description             = "Client secret for Civil Manage API Entra ID OBO authentication",
      recovery_window_in_days = 7,
      k8s_secret_name         = "azure-entra-api-client-secret"
    }
  }
}