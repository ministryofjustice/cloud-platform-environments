module "pre-sentence-service" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "pre-sentence-service"
  github_owner                  = var.github_owner
  application                   = "pre-sentence-service"
  github_team                   = "hmpps-probation-in-court"
  environment                   = var.environment # must match environment name used in helm file
  reviewer_teams                = ["probation-in-court-live", "probation-in-court-devs", "probation-integration"]
  selected_branch_patterns      = ["main", "preprod/*"]
  is_production                 = var.is_production
  application_insights_instance = var.application_insights_instance
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}