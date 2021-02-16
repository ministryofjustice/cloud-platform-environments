module "example_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "cloud-platform-environments"
  team_name = "hmpps-dev-test"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_ecr_credentials" {
  metadata {
    name      = "example-team-ecr-credentials-output"
    namespace = "learning-cloud-deployments-dev"
  }

  data = {
    access_key_id     = module.example_team_ecr_credentials.access_key_id
    secret_access_key = module.example_team_ecr_credentials.secret_access_key
    repo_arn          = module.example_team_ecr_credentials.repo_arn
    repo_url          = module.example_team_ecr_credentials.repo_url
  }
}
