module "hmpps_service_catalogue_template" {
  source         = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.7"
  github_repo    = "hmpps-service-catalogue"
  application    = "hmpps-service-catalogue"
  github_team    = "hmpps-sre"
  environment    = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams = ["hmpps-sre"]   # Optional team that should review deployments to this environment.
  #selected_branch_patterns      = ["main", "release/*", "feature/*", "**"] # Optional but required if protected_branches_only is false
  protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

