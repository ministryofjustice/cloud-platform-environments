module "hmpps_template_typescript" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-accredited-programmes-manage-and-deliver-ui"
  application = "hmpps-accredited-programmes-manage-and-deliver-ui"
  github_team = "hmpps-accredited-programmes-manage-and-deliver-live"
  environment = var.environment
  #reviewer_teams                = ["hmpps-dev-team-1", "hmpps-dev-team-2"] # Optional team that should review deployments to this environment.
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

