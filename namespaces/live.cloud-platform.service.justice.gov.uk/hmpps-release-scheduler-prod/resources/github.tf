module "release-scheduler-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "hmpps-release-scheduler-api"
  application                   = "hmpps-release-scheduler-api"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = [var.team_name, "hmpps-move-and-improve"]
}

module "release-scheduler-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "hmpps-release-scheduler-ui"
  application                   = "hmpps-release-scheduler-ui"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = [var.team_name, "hmpps-move-and-improve"]
}