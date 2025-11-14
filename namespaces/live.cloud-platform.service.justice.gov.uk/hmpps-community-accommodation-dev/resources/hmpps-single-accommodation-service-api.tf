module "hmpps_single_accommodation_service_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-single-accommodation-service-api"
  application = "hmpps-single-accommodation-service-api"
  github_team = "hmpps-community-accommodation-devs"
  environment = var.environment # Should match environment name used in helm values file e.g. values-development.yaml
  # reviewer_teams                = ["approved-premises-team", "hmpps-community-accommodation", "hmpps-community-accommodation-devs"] # Optional team that should review deployments to this environment.
  # selected_branch_patterns      = ["main", "feature-dev/*"] # Optional
  # protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
