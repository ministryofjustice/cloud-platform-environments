module "hmpps_electronic_monitoring_data_insights_utils" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"

  github_repo                   = "hmpps-electronic-monitoring-data-insights-utils"
  application                   = "hmpps-electronic-monitoring-data-insights-utils"
  github_team                   = var.team_name
  environment                   = var.environment
  reviewer_teams                = [var.team_name]
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
