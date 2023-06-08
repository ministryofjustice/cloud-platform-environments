/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_fee_caclulator_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"
  repo_name = var.repo_name
  team_name = var.team_name

  providers = {
    aws = aws.london
  }

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = ["laa-fee-calculator"]

  # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace
}

resource "kubernetes_secret" "laa_fee_caclulator_team_ecr_credentials" {
  metadata {
    name      = "laa-fee-caclulator-team-ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.laa_fee_caclulator_team_ecr_credentials.access_key_id
    secret_access_key = module.laa_fee_caclulator_team_ecr_credentials.secret_access_key
    repo_arn          = module.laa_fee_caclulator_team_ecr_credentials.repo_arn
    repo_url          = module.laa_fee_caclulator_team_ecr_credentials.repo_url
  }
}

