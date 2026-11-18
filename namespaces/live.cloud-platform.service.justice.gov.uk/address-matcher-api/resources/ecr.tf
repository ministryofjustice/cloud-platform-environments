/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers        = ["github"]
  github_repositories   = ["address-matcher-api"]
  github_environments   = ["dev"]
  github_actions_prefix = "dev"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for read only queries,
  # uncomment below:

  # enable_irsa = true
}

# Prod gets its own repository and its own GitHub `prod` environment values
# (PROD_ECR_ROLE_TO_ASSUME, PROD_ECR_REGION, PROD_ECR_REPOSITORY), used by the prod
# deploy workflow.
module "ecr_prod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = "${var.namespace}-prod"

  # OpenID Connect configuration
  oidc_providers        = ["github"]
  github_repositories   = ["address-matcher-api"]
  github_environments   = ["prod"]
  github_actions_prefix = "prod"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
