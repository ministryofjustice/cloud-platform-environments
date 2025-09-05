module "hmpps_authorization" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-authorization"
  application                   = "hmpps-authorization"
  github_team                   = "haha-live"
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = ["haha-live"]
}

module "hmpps-authorization_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-authorization-api"
  application                   = "hmpps-authorization-api"
  github_team                   = "haha-live"
  environment                   = var.environment
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = ["haha-live"]
}