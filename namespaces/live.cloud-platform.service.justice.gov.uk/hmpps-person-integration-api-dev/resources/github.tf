module "hmpps_person_integration_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  input_custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-person-integration-api"
  application                   = "hmpps-person-integration-api"
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
