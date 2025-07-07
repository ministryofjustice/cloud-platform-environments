module "hmpps-prisoner-base-location-api" {
  source      = "github.com/ministryofjustice/hmpps-prisoner-base-location-api"
  github_repo = "hmpps-prisoner-base-location-api"
  application = "hmpps-prisoner-base-location-api"
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
