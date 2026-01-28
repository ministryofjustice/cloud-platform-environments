module "pathfinder" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "pathfinder"
  application                   = "pathfinder"
  github_team                   = "secure-estate-digital-team"
  reviewer_teams                = ["secure-estate-digital-restricted-team"]
  environment                   = var.environment_name
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.environment_name
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}