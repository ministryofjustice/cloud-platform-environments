module "hmpps_template_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-probation-supervision-appointments-api"
  application = "hmpps-probation-supervision-appointments-api"
  github_team = "probation-integration"
  environment = var.environment # Should match environment name used in helm values file e.g. values-prod.yaml
  reviewer_teams                = ["mpop-dev-team"]
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
