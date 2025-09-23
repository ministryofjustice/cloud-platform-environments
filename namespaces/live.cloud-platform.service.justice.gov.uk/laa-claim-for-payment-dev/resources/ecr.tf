/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["laa-claim-for-payment"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ecr-mock-oidc" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = "${var.namespace}-mock-oidc"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["laa-claim-for-payment"]
  github_actions_prefix = "mock_oidc"
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
