/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "gdavies-dev_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "gdavies-dev-repo"
  team_name = "gdavies-dev-team"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "gdavies-dev_ecr_credentials" {
  metadata {
    name      = "gdavies-dev-ecr-credentials-output"
    namespace = "gdavies-dev"
  }

  data {
    access_key_id     = "${module.gdavies-dev_ecr_credentials.access_key_id}"
    secret_access_key = "${module.gdavies-dev_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.gdavies-dev_ecr_credentials.repo_arn}"
    repo_url          = "${module.gdavies-dev_ecr_credentials.repo_url}"
  }
}
