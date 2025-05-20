module "hmpps_one_plan_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-one-plan-api"
  application                   = "hmpps-one-plan-api"
  github_team                   = "hmpps-assessments"
  reviewer_teams                = ["hmpps-assessments"]
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
