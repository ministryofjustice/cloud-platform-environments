/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.1"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["model-metadata-app"]

  # list of github environments, to create the ECR secrets as environment secrets
  # https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets
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
}
