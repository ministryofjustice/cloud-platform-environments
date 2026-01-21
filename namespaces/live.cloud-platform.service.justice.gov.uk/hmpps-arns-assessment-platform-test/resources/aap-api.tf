module "hmpps_arns_assessment_platform_api" {
source                          = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-arns-assessment-platform-api"
  application                   = "hmpps-arns-assessment-platform-api"
  github_team                   = "hmpps-assessments-devs"
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  selected_branch_patterns      = ["*"]
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
