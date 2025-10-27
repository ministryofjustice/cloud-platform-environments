/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"
  namespace = var.namespace

  # OpenID Connect configuration
  oidc_providers        = ["github"]
  github_repositories   = ["laa-data-provider-data"]
  github_actions_prefix = "prod"

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  github_environments = ["prod"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  deletion_protection = false
}
