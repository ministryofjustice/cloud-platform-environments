module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.2"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "gold_scorecard_form_dev_alert_rule" = {
      description             = "secret for goldscorecard form dev alerting rule",
      recovery_window_in_days = 7,
      k8s_secret_name         = "gold-scorecard-form-dev-alert-secret"
    },
  }
}