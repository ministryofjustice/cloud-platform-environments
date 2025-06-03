module "hmpps_subject_access_request_html_renderer" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-subject-access-request-html-renderer"
  application = "hmpps-subject-access-request-html-renderer"
  github_team = var.team_name
  environment = var.environment
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  reviewer_teams                = [var.team_name]
}
