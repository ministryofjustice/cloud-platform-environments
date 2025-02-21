module "hmpps_sentence_plan_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.7"
  github_repo                   = "hmpps-sentence-plan"
  application                   = "hmpps-sentence-plan"
  github_team                   = "hmpps-sentence-planning"
  reviewer_teams                = ["hmpps-sentence-planning"]
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
