module "hmpps_risk_assessment_ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.7"
  github_repo                   = "hmpps-risk-assessment-ui"
  application                   = "hmpps-risk-assessment-ui"
  github_team                   = "hmpps-assessments"
  environment                   = var.environment_name
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["*"]
  kubernetes_cluster            = var.kubernetes_cluster
}
