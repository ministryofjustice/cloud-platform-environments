module "hmpps_electronic_monitoring_crime_matching_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-electronic-monitoring-data-insights-api"
  application = "hmpps-electronic-monitoring-data-insights-api"
  github_team = "hmpps-em-probation"
  environment = var.environment # Should match environment name used in helm values file e.g. values-prod.yaml
  reviewer_teams                = ["hmpps-em-probation"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main"] # Optional
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}