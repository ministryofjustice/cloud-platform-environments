/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = [var.repo_name, "cla_public", "cla_backend", "cla_frontend", "fala"]

    # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials.access_key_id
    secret_access_key = module.ecr_credentials.secret_access_key
    repo_arn          = module.ecr_credentials.repo_arn
    repo_url          = module.ecr_credentials.repo_url
  }
}
