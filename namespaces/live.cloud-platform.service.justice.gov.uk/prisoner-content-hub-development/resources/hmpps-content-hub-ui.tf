module "hmpps_content_hub_ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-content-hub-ui"
  application = "hmpps-content-hub-ui"
  github_team = "hmpps-launchpad"
  environment = var.environment-name # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-launchpad"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "**/**", "**"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
