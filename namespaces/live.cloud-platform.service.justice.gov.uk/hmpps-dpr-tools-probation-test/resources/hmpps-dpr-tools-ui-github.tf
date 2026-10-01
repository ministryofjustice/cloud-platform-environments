module "hmpps_dpr_tools_ui_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"

  github_repo                    = "hmpps-dpr-tools-ui"
  application                    = "hmpps-dpr-tools-ui-probation"
  github_team                    = var.team_name
  environment                    = "probation-test"
  is_production                  = var.is_production
  application_insights_instance = "dev"

  selected_branch_patterns = [
    "main",
  ]

  source_template_repo = "hmpps-template-kotlin"
  github_token         = var.github_token
  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
}