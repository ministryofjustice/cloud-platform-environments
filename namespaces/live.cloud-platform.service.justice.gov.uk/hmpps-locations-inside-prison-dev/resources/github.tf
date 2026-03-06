module "hmpps-locations-inside-prison-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-locations-inside-prison-api"
  application                   = "hmpps-locations-inside-prison-api"
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
}

module "hmpps-locations-inside-prison" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-locations-inside-prison"
  application                   = "hmpps-locations-inside-prison"
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
}

module "hmpps-non-residential-locations-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-non-residential-locations-ui"
  application                   = "hmpps-non-residential-locations-ui"
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
}
