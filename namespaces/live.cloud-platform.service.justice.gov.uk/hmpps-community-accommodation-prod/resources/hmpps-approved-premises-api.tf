module "hmpps_approved_premises_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  input_custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-approved-premises-api"
  application = "hmpps-approved-premises-api"
  github_team = "hmpps-community-accommodation"
  environment = var.environment # Should match environment name used in helm values file e.g. values-development.yaml
  reviewer_teams                = ["hmpps-community-accommodation-live"] # Optional team that should review deployments to this environment.
  # selected_branch_patterns      = ["main"] # Optional
  protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
