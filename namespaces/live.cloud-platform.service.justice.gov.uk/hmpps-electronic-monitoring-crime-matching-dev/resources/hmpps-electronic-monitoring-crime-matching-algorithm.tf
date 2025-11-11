locals {
  crime_matching_algorithm_repo = "hmpps-electronic-monitoring-crime-matching-algorithm"
}

module "hmpps_electronic_monitoring_crime_matching_algorithm" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = local.crime_matching_algorithm_repo
  application                   = local.crime_matching_algorithm_repo
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

module "hmpps_electronic_monitoring_crime_matching_algorithm_container_repository" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = local.crime_matching_algorithm_repo

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = [local.crime_matching_algorithm_repo]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
