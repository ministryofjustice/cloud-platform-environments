module "hmpps_electronic_monitoring_crime_matching_algorithm" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-electronic-monitoring-crime-matching-algorithm"
  application                   = "hmpps-electronic-monitoring-crime-matching-algorithm"
  github_team                   = "hmpps-em-probation-devs"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = [] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
