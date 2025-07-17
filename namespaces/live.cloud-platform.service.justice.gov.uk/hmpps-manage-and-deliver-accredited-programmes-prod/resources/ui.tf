module "hmpps_template_typescript" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-accredited-programmes-manage-and-deliver-ui"
  application = "hmpps-accredited-programmes-manage-and-deliver-ui"
  github_team = "hmpps-accredited-programmes-manage-and-deliver-devs"
  environment = var.environment
  reviewer_teams                = ["hmpps-accredited-programmes-manage-and-deliver-devs"]
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

