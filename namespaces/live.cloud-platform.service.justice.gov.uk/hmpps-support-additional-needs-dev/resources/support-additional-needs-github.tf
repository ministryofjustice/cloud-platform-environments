module "support-additional-needs-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-support-additional-needs-api"
  application                   = "hmpps-support-additional-needs-api"
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
}

module "support-additional-needs-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-support-additional-needs-ui"
  application                   = "hmpps-support-additional-needs-ui"
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
}
