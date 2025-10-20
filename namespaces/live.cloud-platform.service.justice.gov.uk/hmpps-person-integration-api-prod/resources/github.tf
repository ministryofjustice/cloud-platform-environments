module "hmpps_person_integration_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-person-integration-api"
  application                   = "hmpps-person-integration-api"
  github_team                   = "connect-dps"
  reviewer_teams                = ["connect-dps", "hmpps-person-record"]
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["main"]
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
