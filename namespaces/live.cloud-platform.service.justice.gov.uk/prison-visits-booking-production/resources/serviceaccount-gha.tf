module "prison-visits-public" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "prison-visits-public"
  application = "prison-visits-public"
  github_team = "hmpps-prison-visits-booking-live"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-prison-visits-booking-live"] # Optional team that should review deployments to this environment.
  # selected_branch_patterns      = ["main", "**/**", "**"] # Optional
  protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "prison-visits-staff" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "prison-visits-2"
  application = "prison-visits-staff"
  github_team = "hmpps-prison-visits-booking-live"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-prison-visits-booking-live"] # Optional team that should review deployments to this environment.
  # selected_branch_patterns      = ["main", "**/**", "**"] # Optional
  protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
