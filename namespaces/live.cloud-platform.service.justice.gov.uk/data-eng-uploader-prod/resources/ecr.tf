/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_credentials" {
  source         = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"
  team_name      = var.team_name
  repo_name      = "${var.namespace}-ecr"
  oidc_providers = ["github"]

  # repository names to create github actions secrets
  # containing the ECR name, AWS access key, and AWS secret key, for use in
  # github actions CI/CD pipelines
  github_repositories = ["analytical-platform-uploader"]

  # list of github environments, to create the ECR secrets as environment secrets
  # https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets
  github_environments = ["prod"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
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
    ecr_role = module.ecr_credentials.irsa_policy_arn
  }
}
