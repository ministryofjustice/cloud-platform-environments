/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["payforlegalaid", "payforlegalaid-ui"]
  github_environments = ["development"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # For ECR creation to differentiate between environments
  github_actions_prefix = "dev"
}

module "testing_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name = var.testing_ecr

  oidc_providers      = ["github"]
  github_repositories = ["payforlegalaid", "payforlegalaid-tests"]
  github_environments = ["development"]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  github_actions_prefix = "dev_test"
}

module "data_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name = var.data_ecr

  oidc_providers      = ["github"]
  github_repositories = ["payforlegalaid", "payforlegalaid-data"]
  github_environments = ["development"]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  github_actions_prefix = "dev_data"
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr.repo_arn
    repo_url = module.ecr.repo_url
    tests_repo_arn = module.testing_ecr.repo_arn
    tests_repo_url = module.testing_ecr.repo_url
    data_repo_arn = module.data_ecr.repo_arn
    data_repo_url = module.data_ecr.repo_url
  }
}
