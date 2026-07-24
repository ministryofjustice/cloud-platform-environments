module "hmpps-supervision" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "hmpps-supervision"
  selected_branch_patterns      = ["main"]
  source_template_repo          = "none"
  application                   = var.application
  github_owner                  = var.github_owner
  github_team                   = var.team_name
  github_token                  = var.github_token
  environment                   = var.environment_name
  application_insights_instance = var.environment_name
  is_production                 = var.is_production
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
