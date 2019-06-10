/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.3"
  repo_name = "reference-app"
  team_name = "cloud-platform"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "example_team_ecr_credentials" {
  metadata {
    name      = "cloud-platform-ecr-credentials-output"
    namespace = "demo-app"
  }

  data {
    access_key_id     = "${module.example_team_ecr_credentials.access_key_id}"
    secret_access_key = "${module.example_team_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.example_team_ecr_credentials.repo_arn}"
    repo_url          = "${module.example_team_ecr_credentials.repo_url}"
  }
}
