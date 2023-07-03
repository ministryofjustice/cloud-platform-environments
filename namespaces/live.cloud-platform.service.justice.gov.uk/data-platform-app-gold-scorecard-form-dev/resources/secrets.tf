module "secrets_manager" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=2.0.0"
  team_name               = var.team_name
  application             = var.application
  business_unit           = var.business_unit
  is_production           = var.is_production
  namespace               = var.namespace
  environment             = var.environment
  infrastructure_support  = var.infrastructure_support
  kubernetes_cluster       = var.kubernetes_cluster

  secrets = {
    "gold_scorecard_form_dev_alert_rule" = {
      description             = "secret for goldscorecard form dev alerting rule", 
      recovery_window_in_days = 7,
      k8s_secret_name        = "gold-scorecard-form-dev-alert-secret"
    },
  }
}