module "hmpps_assessments_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.7"
  github_repo                   = "hmpps-assessments-api"
  application                   = "hmpps-assessments-api"
  github_team                   = "hmpps-assessments"
  reviewer_teams                = ["hmpps-assessments"]
  environment                   = var.environment_name
  is_production                 = var.is_production
  application_insights_instance = "preprod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
