module "hmpps_court_cases_release_dates" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-court-cases-release-dates"
  application = "hmpps-court-cases-release-dates"
  github_team = var.team_name
  environment = var.environment_name
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment_name # Either "dev", "preprod" or "prod"
  reviewer_teams = [var.github_actions_team]
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
module "hmpps_court_cases_release_dates_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-court-cases-release-dates-api"
  application = "hmpps-court-cases-release-dates-api"
  github_team = var.team_name
  environment = var.environment_name
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment_name # Either "dev", "preprod" or "prod"
  reviewer_teams = [var.github_actions_team]
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}