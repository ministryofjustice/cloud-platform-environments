module "hmpps-electronic-monitoring-data-insights-api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo = "hmpps-electronic-monitoring-data-insights-api"
  application = "hmpps-electronic-monitoring-data-insights-api"
  github_team = var.team_name
  environment = var.environment # Should match environment name used in helm values file e.g. values-preprod.yaml
  reviewer_teams                = [var.team_name] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main"] # Optional
  is_production                 = var.is_production
  application_insights_instance = var.environment # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}