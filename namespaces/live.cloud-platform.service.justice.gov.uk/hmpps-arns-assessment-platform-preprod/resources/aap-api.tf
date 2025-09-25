module "hmpps_arns_assessment_platform_api" {
source                          = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-arns-assessment-platform-api"
  application                   = "hmpps-arns-assessment-platform-api"
  github_team                   = "hmpps-assessments-live"
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "preprod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
