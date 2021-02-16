/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "proffe_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "proffe-repo"
  team_name = "hmpps-dev-test"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_ecr_credentials" {
  metadata {
    name      = "proffe-ecr-credentials-output"
    namespace = "proffeapp-dev"
  }

  data = {
    access_key_id     = module.proffe_ecr_credentials.access_key_id
    secret_access_key = module.proffe_ecr_credentials.secret_access_key
    repo_arn          = module.proffe_ecr_credentials.repo_arn
    repo_url          = module.proffe_ecr_credentials.repo_url
  }
}

