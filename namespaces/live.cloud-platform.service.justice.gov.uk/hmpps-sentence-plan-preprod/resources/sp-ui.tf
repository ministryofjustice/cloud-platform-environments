module "hmpps_sentence_plan_ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  input_custom_token_rotation_date = "2026-03-20"
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
