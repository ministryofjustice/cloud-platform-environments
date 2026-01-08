module "hmpps_single_accommodation_service_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-single-accommodation-service-api"
  application                   = "hmpps-single-accommodation-service-api"
  github_team                   = "hmpps-community-accommodation"
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  reviewer_teams                = ["hmpps-community-accommodation-live"]
}
