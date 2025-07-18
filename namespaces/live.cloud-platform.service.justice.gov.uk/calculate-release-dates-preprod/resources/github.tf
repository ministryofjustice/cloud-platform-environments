module "calculate_release_dates_ui_preprod" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "calculate-release-dates"
  application = "calculate-release-dates"
  github_team = var.team_name
  environment = "preprod"
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment # Either "dev", "preprod" or "prod"
  reviewer_teams = [var.github_actions_team]
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "calculate_release_dates_ui_alt_preprod" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "calculate-release-dates"
  application = "calculate-release-dates-alt"
  github_team = var.team_name
  environment = "alt-preprod"
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment # Either "dev", "preprod" or "prod"
  reviewer_teams = [var.github_actions_team]
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
