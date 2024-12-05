/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_crime_apps_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"
  repo_name = "laa-court-data-adaptor"
  team_name = "laa-crime-apps-team"
  namespace = var.namespace

  oidc_providers = ["circleci"]

  github_repositories = ["laa-court-data-adaptor"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa_crime_apps_team_ecr_credentials" {
  metadata {
    name      = "laa-crime-apps-team-ecr-credentials-output"
    namespace = "laa-court-data-adaptor-dev"
  }

  data = {
    repo_arn = module.laa_crime_apps_team_ecr_credentials.repo_arn
    repo_url = module.laa_crime_apps_team_ecr_credentials.repo_url
  }
}
