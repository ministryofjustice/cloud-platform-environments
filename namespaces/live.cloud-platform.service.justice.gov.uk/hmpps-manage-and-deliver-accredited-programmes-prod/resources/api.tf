module "hmpps_template_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-accredited-programmes-manage-and-deliver-api"
  application = "hmpps-accredited-programmes-manage-and-deliver-api"
  github_team = "hmpps-accredited-programmes-manage-and-deliver-devs"
  environment = var.environment
  reviewer_teams                = ["hmpps-accredited-programmes-manage-and-deliver-devs"]
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = var.environment # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}