/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

# One module instantiation for each repo

module "ecr-james-typescript-test" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = "james-typescript-test"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["james-typescript-test"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false
  # Just this one can have the irsa
  enable_irsa = true
}

module "ecr-james-kotlin-test" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = "james-kotlin-test"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["james-kotlin-test"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false
}

module "ecr-hmpps-james-bootstrap" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = "hmpps-james-bootstrap"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["hmpps-james-bootstrap"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false
}
