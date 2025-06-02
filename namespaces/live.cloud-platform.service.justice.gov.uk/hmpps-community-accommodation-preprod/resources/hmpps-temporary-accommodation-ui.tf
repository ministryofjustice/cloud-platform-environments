module "hmpps_community_accommodation" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-temporary-accommodation-ui"
  application = "hmpps-temporary-accommodation-ui"
  github_team = "hmpps-community-accommodation"
  environment = var.environment # Should match environment name used in helm values file e.g. values-development.yaml
  reviewer_teams                = ["hmpps-temporary-accommodation", "hmpps-community-accommodation", "hmpps-community-accommodation-live"] # Optional team that should review deployments to this environment.
  # selected_branch_patterns      = ["main"] # Optional
  protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

