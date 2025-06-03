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
  github_repositories = ["mbpr-test"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  github_environments    = [var.environment]
  github_actions_secret_kube_cluster = var.github_actions_secret_kube_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token = var.github_actions_secret_kube_token
  github_actions_secret_ecr_name = var.github_actions_secret_ecr_name
  github_actions_secret_ecr_url = var.github_actions_secret_ecr_url
}

resource "kubernetes_secret" "ecr" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr.repo_arn
    repo_url = module.ecr.repo_url
  }
}