module "mandatory-drug-testing-api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo = "hmpps-mandatory-drug-testing-api"
  application = "hmpps-mandatory-drug-testing-api"
  github_team = var.team_name
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  selected_branch_patterns      = ["main"]
  reviewer_teams                = ["hmpps-move-and-improve"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "release/*", "feature/*", "bug/*", "**"] # Optional but required if protected_branches_only is false
  protected_branches_only       = false          # Optional, defaults to true unless selected_branch_patterns is set
}

module "mandatory-drug-testing-ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo = "hmpps-mandatory-drug-testing-ui"
  application = "hmpps-mandatory-drug-testing-ui"
  github_team = var.team_name
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  selected_branch_patterns      = ["main"]
  reviewer_teams                = ["hmpps-move-and-improve"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "release/*", "feature/*", "bug/*", "**"] # Optional but required if protected_branches_only is false
  protected_branches_only       = false     # Optional, defaults to true unless selected_branch_patterns is set
}