module "hmpps_template_kotlin" {
<<<<<<< SRF-40-infra-prod
  source         = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo    = "hmpps-suicide-risk-form-api"
  application    = "hmpps-suicide-risk-form-api"
  github_team    = "unilink"
  reviewer_teams = ["unilink"]
  environment    = var.environment_name # Should match environment name used in helm values file e.g. values-dev.yaml
  #reviewer_teams                = ["hmpps-dev-team-1", "hmpps-dev-team-2"] # Optional team that should review deployments to this environment.
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
=======
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-suicide-risk-form-api"
  application                   = "hmpps-suicide-risk-form-api"
  github_team                   = "unilink"
  reviewer_teams                = ["unilink"]
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
>>>>>>> local
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "prod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
