module "hmpps_template_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-31"
  github_repo = "hmpps-warrant-risk-assessment-api"
  application = "hmpps-warrant-risk-assessment-api"
  github_team = "unilink"
  environment = var.environment_name # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["unilink_admin"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main"] # Optional
  # protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
