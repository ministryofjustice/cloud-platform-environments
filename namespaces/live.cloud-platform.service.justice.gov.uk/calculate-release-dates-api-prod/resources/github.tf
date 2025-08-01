module "calculate_release_dates_api_prod" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "calculate-release-dates-api"
  application = "calculate-release-dates-api"
  github_team = var.team_name
  environment = var.environment
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment # Either "dev", "preprod" or "prod"
  reviewer_teams                = [var.github_actions_team]
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
