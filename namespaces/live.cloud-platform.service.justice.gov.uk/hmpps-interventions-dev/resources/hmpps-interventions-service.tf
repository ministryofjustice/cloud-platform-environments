module "hmpps_template_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-interventions-service"
  application = "hmpps-interventions-service"
  github_team = "hmpps-interventions-dev"
  environment = var.environment
  selected_branch_patterns      = ["main", "hotfix/*"]
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
