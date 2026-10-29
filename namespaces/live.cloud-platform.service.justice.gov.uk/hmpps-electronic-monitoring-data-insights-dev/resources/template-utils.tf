locals {
  data_insights_utils_repo = "hmpps-electronic-monitoring-data-insights-utils"
}

module "hmpps_electronic_monitoring_data_insights_utils" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token         = true
  custom_token_rotation_date = "2026-03-20"

  github_repo                   = local.data_insights_utils_repo
  application                   = local.data_insights_utils_repo
  github_team                   = "hmpps-em-probation-devs"
  environment                   = var.environment
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps_electronic_monitoring_data_insights_utils_container_repository" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  repo_name = local.data_insights_utils_repo

  oidc_providers      = ["github"]
  github_repositories = [local.data_insights_utils_repo]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
