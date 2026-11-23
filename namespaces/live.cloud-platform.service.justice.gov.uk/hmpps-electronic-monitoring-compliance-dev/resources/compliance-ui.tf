module "hmpps_electronic_monitoring_compliance_ui" {
  source                         = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"
  force_rotate_token             = true
  custom_token_rotation_date     = "2026-03-20"
  github_repo                    = "hmpps-electronic-monitoring-compliance-ui"
  application                    = "hmpps-electronic-monitoring-compliance-ui"
  github_team                    = "hmpps-electronic-monitoring-devs"
  environment                    = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                  = var.is_production
  application_insights_instance  = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo           = "hmpps-template-typescript"
  github_token                   = var.github_token
  namespace                      = var.namespace
  kubernetes_cluster             = var.kubernetes_cluster
}


