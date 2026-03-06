module "github-automation" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-micro-frontend-components"
  application                   = "hmpps-micro-frontend-components"
  github_team                   = var.github_review_team
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  reviewer_teams                = [var.github_deployment_team]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
