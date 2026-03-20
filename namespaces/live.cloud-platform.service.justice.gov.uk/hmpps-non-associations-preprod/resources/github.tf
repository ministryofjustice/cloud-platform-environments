module "hmpps-non-associations" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  input_custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-non-associations"
  application                   = "hmpps-non-associations"
  github_team                   = var.team_name
  environment                   = var.deployment_environment
  is_production                 = var.is_production
  protected_branches_only       = true
  reviewer_teams                = [var.team_name]
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "hmpps-non-associations-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  input_custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-non-associations-api"
  application                   = "hmpps-non-associations-api"
  github_team                   = var.team_name
  environment                   = var.deployment_environment
  is_production                 = var.is_production
  protected_branches_only       = true
  reviewer_teams                = [var.team_name]
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
