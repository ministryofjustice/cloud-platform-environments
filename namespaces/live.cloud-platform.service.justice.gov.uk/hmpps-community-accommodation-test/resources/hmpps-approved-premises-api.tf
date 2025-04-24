module "hmpps_approved_premises_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-approved-premises-api"
  application = "hmpps-approved-premises-api"
  github_team = "hmpps-community-accommodation"
  environment = var.environment # Should match environment name used in helm values file e.g. values-development.yaml
  reviewer_teams                = ["approved-premises-team", "hmpps-community-accommodation"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["*"] # Optional -- we allow deploying any branch to test, as it is decoupled from the main pipeline
  # protected_branches_only       = false # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
