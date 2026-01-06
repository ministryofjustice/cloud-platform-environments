module "hmpps_health_and_medication_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-health-and-medication-api"
  application                   = "hmpps-health-and-medication-api"
  github_team                   = var.github_review_team
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["main"]
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
