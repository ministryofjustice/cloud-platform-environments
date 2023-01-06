/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_crime_apps_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=bump-key"
  repo_name = "hmcts-common-platform-mock-api"
  team_name = "laa-crime-apps-team"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa_crime_apps_team_ecr_credentials" {
  metadata {
    name      = "laa-crime-apps-team-ecr-credentials-output"
    namespace = "hmcts-mock-api-dev"
  }

  data = {
    access_key_id     = module.laa_crime_apps_team_ecr_credentials.access_key_id
    secret_access_key = module.laa_crime_apps_team_ecr_credentials.secret_access_key
    repo_arn          = module.laa_crime_apps_team_ecr_credentials.repo_arn
    repo_url          = module.laa_crime_apps_team_ecr_credentials.repo_url
  }
}

