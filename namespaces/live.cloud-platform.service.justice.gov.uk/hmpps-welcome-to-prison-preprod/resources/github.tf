module "hmpps-welcome-people-into-prison-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-welcome-people-into-prison-api"
  application                   = "hmpps-welcome-people-into-prison-api"
  github_team                   = var.deployment_team_name
  environment                   = var.deployment_environment
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = [ var.review_team_name ]
}

module "hmpps-welcome-people-into-prison-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-welcome-people-into-prison-ui"
  application                   = "hmpps-welcome-people-into-prison-ui"
  github_team                   = var.deployment_team_name
  environment                   = var.deployment_environment
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = [ var.review_team_name ]
}