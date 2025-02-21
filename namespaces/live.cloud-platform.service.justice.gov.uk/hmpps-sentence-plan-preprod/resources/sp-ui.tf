module "hmpps_sentence_plan_ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.7"
  github_repo                   = "hmpps-sentence-plan-ui"
  application                   = "hmpps-sentence-plan-ui"
  github_team                   = "hmpps-sentence-planning"
  reviewer_teams                = ["hmpps-sentence-planning"]
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "preprod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
