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
    "maat_api_env_variables" = {
      description             = "MAAT API Environment variables",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-env-variables"
    },
    "maat_api_alert_webhook_prod" = {
      description             = "MAAT API Slack Webhook",
      recovery_window_in_days = 7,
      k8s_secret_name         = "maat-api-alert-webhook-prod"
    },
  }
}