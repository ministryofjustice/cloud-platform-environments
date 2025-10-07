module "help-with-prison-visits-asynchronous-worker" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "help-with-prison-visits-asynchronous-worker"
  application = "help-with-prison-visits-asynchronous-worker"
  github_team = "hmpps-help-with-prison-visits-live"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  #reviewer_teams                = ["hmpps-help-with-prison-visits-live", "hmpps-dev-team-2"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "**/**", "**"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "help-with-prison-visits-external" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "help-with-prison-visits-external"
  application = "help-with-prison-visits-external"
  github_team = "hmpps-help-with-prison-visits-live"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  #reviewer_teams                = ["hmpps-help-with-prison-visits-live", "hmpps-dev-team-2"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "**/**", "**"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "help-with-prison-visits-internal" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "help-with-prison-visits-internal"
  application = "help-with-prison-visits-internal"
  github_team = "hmpps-help-with-prison-visits-live"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  #reviewer_teams                = ["hmpps-help-with-prison-visits-live", "hmpps-dev-team-2"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "**/**", "**"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
