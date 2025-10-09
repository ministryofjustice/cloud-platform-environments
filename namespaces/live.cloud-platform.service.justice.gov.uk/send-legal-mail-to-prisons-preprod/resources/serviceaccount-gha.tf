module "send-legal-mail-to-prisons" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "send-legal-mail-to-prisons"
  application = "send-legal-mail-to-prisons"
  github_team = "hmpps-send-legal-mail-live"
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

module "send-legal-mail-to-prisons-api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "send-legal-mail-to-prisons-api"
  application = "send-legal-mail-to-prisons-api"
  github_team = "hmpps-send-legal-mail-live"
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

module "hmpps-send-legal-mail-staff-ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-send-legal-mail-staff-ui"
  application = "hmpps-send-legal-mail-staff-ui"
  github_team = "hmpps-send-legal-mail-live"
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
