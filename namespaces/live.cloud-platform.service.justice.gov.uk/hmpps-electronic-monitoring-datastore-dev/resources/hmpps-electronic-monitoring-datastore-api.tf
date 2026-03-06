module "hmpps_electronic_monitoring_datastore_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-electronic-monitoring-datastore-api"
  application = "hmpps-electronic-monitoring-datastore-api"
  github_team = "hmpps-electronic-monitoring"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-electronic-monitoring", "hmpps-em-probation-devs"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
