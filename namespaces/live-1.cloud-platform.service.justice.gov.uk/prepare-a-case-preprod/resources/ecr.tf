/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.0"
  repo_name = "prepare-a-case"
  team_name = "probation-in-court"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_ecr_credentials" {
  metadata {
    name      = "prepare-a-case-ecr-credentials-output"
    namespace = "prepare-a-case-preprod"
  }

  data = {
    access_key_id     = module.example_team_ecr_credentials.access_key_id
    secret_access_key = module.example_team_ecr_credentials.secret_access_key
    repo_arn          = module.example_team_ecr_credentials.repo_arn
    repo_url          = module.example_team_ecr_credentials.repo_url
  }
}

