module "hmpps_probation_demo_ui_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"

  github_repo                   = "hmpps-digital-prison-reporting-demo-ui"
  application                   = "hmpps-probation-demo-ui"
  github_team                   = var.team_name
  environment                   = "probation-prod"
  is_production                 = var.is_production
  application_insights_instance = "prod"
  selected_branch_patterns      = ["main"]
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
