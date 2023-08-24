module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=2.0.0"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment            = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "crime-apps-adaptor-alert-webhook-dev" = {
      description             = "Crime Applications Adaptor Slack Webhook",
      recovery_window_in_days = 7,
      k8s_secret_name         = "crime-apps-adaptor-alert-webhook-dev"
    },
  }
}