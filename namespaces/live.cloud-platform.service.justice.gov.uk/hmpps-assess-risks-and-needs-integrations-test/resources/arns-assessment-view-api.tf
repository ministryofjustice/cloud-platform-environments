module "hmpps_arns_assessment_view_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-arns-assessment-view-api"
  application                   = "hmpps-arns-assessment-view-api"
  github_team                   = "hmpps-assessments"
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  selected_branch_patterns      = ["*"]
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
