module "hmpps-appointment-reminders-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotated_date = "20-03-2026"
  github_repo                   = "hmpps-appointment-reminders-ui"
  application                   = var.application
  github_team                   = var.team_name
  environment                   = var.environment_name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment_name
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}