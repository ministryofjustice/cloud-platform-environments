module "serviceaccount_github" {
  source                   = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo              = "hmpps-complexity-of-need"
  application              = "hmpps-complexity-of-need"
  github_team              = var.team_name
  environment              = var.environment
  is_production            = var.is_production
  selected_branch_patterns = ["main"]
  reviewer_teams           = [var.team_name]
  source_template_repo     = "none"
  github_token             = var.github_token
  namespace                = var.namespace
  kubernetes_cluster       = var.kubernetes_cluster
}
