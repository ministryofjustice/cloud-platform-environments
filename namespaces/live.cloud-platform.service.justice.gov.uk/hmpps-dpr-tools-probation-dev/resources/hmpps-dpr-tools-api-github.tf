module "hmpps_dpr_tools_api_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"

  github_repo                    = "hmpps-dpr-tools-api"
  application                    = "hmpps-dpr-tools-api-probation"
  github_team                    = var.team_name
  environment                    = "probation-dev"
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