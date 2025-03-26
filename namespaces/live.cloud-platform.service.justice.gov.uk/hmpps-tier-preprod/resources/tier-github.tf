module "hmpps-tier-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-tier"
  application                   = "hmpps-tier"
  github_team                   = var.team_name
  environment                   = var.environment_name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment_name
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "hmpps-tier-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-tier-ui"
  application                   = "hmpps-tier-ui"
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