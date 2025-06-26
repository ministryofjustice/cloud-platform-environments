module "hmpps_adjustments_ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-adjustments"
  application = "hmpps-adjustments"
  github_team = var.github_actions_team
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

module "hmpps_adjustments_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-adjustments-api"
  application = "hmpps-adjustments-api"
  github_team = var.github_actions_team
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