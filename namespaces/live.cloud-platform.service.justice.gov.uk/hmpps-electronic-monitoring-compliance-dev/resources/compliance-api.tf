module "hmpps_electronic_monitoring_compliance_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"
  force_rotate_token            = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-electronic-monitoring-compliance-api"
  application                   = "hmpps-electronic-monitoring-compliance-api"
  github_team                   = "hmpps-electronic-monitoring-devs"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = [] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main"] # Optional
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
