/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name = "${var.namespace}-ecr"

  oidc_providers      = ["circleci"]
  github_repositories = ["laa-court-data-api"]

  # Tags
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  # TODO: use var.team_name when we are ready to switch to a new ECR repo
  team_name              = "laa-assess-a-claim" # also used for naming the container repository
  namespace              = var.namespace        # also used for creating a Kubernetes ConfigMap
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
