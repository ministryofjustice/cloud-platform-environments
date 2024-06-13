/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_fee_caclulator_team_ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  repo_name = var.repo_name

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = ["laa-fee-calculator"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa_fee_caclulator_team_ecr_credentials" {
  metadata {
    name      = "laa-fee-caclulator-team-ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.laa_fee_caclulator_team_ecr_credentials.repo_arn
    repo_url = module.laa_fee_caclulator_team_ecr_credentials.repo_url
  }
}
