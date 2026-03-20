module "hmpps_assess_risks_and_needs_handover_service" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-assess-risks-and-needs-handover-service"
  application                   = "hmpps-assess-risks-and-needs-handover-service"
  github_team                   = "hmpps-assessments"
  reviewer_teams                = ["hmpps-assessments", "hmpps-sentence-planning"]
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
