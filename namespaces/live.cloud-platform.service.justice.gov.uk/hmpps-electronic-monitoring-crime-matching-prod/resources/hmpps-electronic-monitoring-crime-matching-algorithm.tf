locals {
  crime_matching_algorithm_repo = "hmpps-electronic-monitoring-crime-matching-algorithm"
}

module "hmpps_electronic_monitoring_crime_matching_algorithm" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = local.crime_matching_algorithm_repo
  application                   = local.crime_matching_algorithm_repo
  github_team                   = "hmpps-em-probation-devs"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-em-probation-devs"]
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
