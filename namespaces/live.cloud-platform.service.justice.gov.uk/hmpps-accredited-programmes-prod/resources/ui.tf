module "hmpps_template_typescript" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  input_custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-accredited-programmes-ui"
  application = "hmpps-accredited-programmes-ui"
  github_team = "hmpps-accredited-programmes-manage-and-deliver-devs"
  environment = "prod"
  reviewer_teams                = ["hmpps-accredited-programmes-manage-and-deliver-devs"]
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
