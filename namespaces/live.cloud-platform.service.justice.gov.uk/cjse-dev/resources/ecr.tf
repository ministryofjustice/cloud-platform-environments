/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ingestion_api_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.1"

  # Repository configuration
  repo_name = "xhibit-ingestion-api"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["moj-cjse-xhibit-ingestion-api"]
  github_environments = ["dev"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ingestion_processor_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.1"

  # Repository configuration
  repo_name = "xhibit-ingestion-processor"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["moj-cjse-xhibit-ingestion-processor"]
  github_environments = ["dev"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}