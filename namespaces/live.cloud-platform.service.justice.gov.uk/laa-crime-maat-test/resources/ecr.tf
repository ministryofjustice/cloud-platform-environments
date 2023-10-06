/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "ecr_credentials" {
  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"
  namespace = var.namespace

  # specify which GitHub repository you're pushing from
  github_repositories = ["laa-crimeapps-maat-functional-tests"]

  # set this if you use one GitHub repository to push to multiple container repositories
  # this ensures the variable key used in the workflow is unique

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_credentials.repo_arn
    repo_url = module.ecr_credentials.repo_url
  }
}
