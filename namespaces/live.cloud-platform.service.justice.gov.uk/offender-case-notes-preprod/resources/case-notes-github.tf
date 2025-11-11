module "case-notes-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "offender-case-notes"
  application                   = "offender-case-notes"
  github_team                   = var.team_name
  environment                   = var.environment-name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment-name
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = [var.team_name]
}
