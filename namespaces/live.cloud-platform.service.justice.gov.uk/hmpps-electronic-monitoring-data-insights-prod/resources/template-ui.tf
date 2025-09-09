module "hmpps_template_typescript" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-electronic-monitoring-data-insights-ui"
  application = "hmpps-electronic-monitoring-data-insights-ui"
  github_team = "hmpps-em-probation-live"
  environment = var.environment 
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}