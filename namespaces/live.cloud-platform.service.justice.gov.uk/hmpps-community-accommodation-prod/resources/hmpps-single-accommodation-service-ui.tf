module "hmpps_single_accommodation_service_ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-single-accommodation-service-ui"
  application                   = "hmpps-single-accommodation-service-ui"
  github_team                   = "hmpps-community-accommodation"
  environment                   = var.environment
  reviewer_teams                = ["hmpps-community-accommodation-live"]
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
