module "hmpps_assess_risks_and_needs_coordinator_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.7"
  github_repo                   = "hmpps-assess-risks-and-needs-coordinator-api"
  application                   = "hmpps-assess-risks-and-needs-coordinator-api"
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
