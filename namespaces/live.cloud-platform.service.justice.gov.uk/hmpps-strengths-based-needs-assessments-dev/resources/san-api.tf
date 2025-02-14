module "hmpps_strengths_based_needs_assessments_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.7"
  github_repo                   = "hmpps-strengths-based-needs-assessments-api"
  application                   = "hmpps-strengths-based-needs-assessments-api"
  github_team                   = "hmpps-assessments"
  environment                   = var.environment_name
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  protected_branches_only       = false
  kubernetes_cluster            = var.kubernetes_cluster
}
