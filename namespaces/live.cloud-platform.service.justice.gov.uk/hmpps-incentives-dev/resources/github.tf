module "hmpps-incentives-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-incentives-ui"
  application                   = "hmpps-incentives-ui"
  github_team                   = var.team_name
  environment                   = var.deployment_environment
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "hmpps-incentives-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-incentives-api"
  application                   = "hmpps-incentives-api"
  github_team                   = var.team_name
  environment                   = var.deployment_environment
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
