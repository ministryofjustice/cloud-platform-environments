/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "markberridge-dev-ecr-credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "markberridge-dev-repo"
  team_name = "markberridge-dev-team"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "markberridge-dev-ecr-credentials" {
  metadata {
    name      = "markberridge-dev-team-ecr-credentials-output"
    namespace = "markberridge-dev"
  }

  data = {
    access_key_id     = module.markberridge-dev-ecr-credentials.access_key_id
    secret_access_key = module.markberridge-dev-ecr-credentials.secret_access_key
    repo_arn          = module.markberridge-dev-ecr-credentials.repo_arn
    repo_url          = module.markberridge-dev-ecr-credentials.repo_url
  }
}

