/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

# One module instantiation for each repo

module "ecr_dependencytrack_apiserver" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = "hmpps-dependencytrack-apiserver"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["hmpps-dependencytrack"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false
  github_actions_prefix  = "APISERVER"
  # Just this one can have the irsa
  enable_irsa = true
}

module "ecr_dependencytrack_frontend" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = "hmpps-dependencytrack-frontend"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["hmpps-dependencytrack"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false
  github_actions_prefix  = "FRONTEND"
  # Just this one can have the irsa
  enable_irsa = true
}

// We need to add a variable which contains the registry as we can't pass secrets through to the helm additional args:
resource "github_actions_variable" "dependencytrack_ecr_registry" {
  repository    = "hmpps-dependencytrack"
  variable_name = "CLOUD_PLATFORM_ECR_REGISTRY_URL"
  value         = split("/", module.ecr_dependencytrack_apiserver.repo_url)[0]
}