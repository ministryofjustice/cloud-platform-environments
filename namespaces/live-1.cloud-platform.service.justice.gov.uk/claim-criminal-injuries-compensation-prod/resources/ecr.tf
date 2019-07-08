/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest versions listed on the
 * releases page of this repository
 *
 */
module "cica_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "cica-repo-prod"
  team_name = "cica"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr_repo" {
  metadata {
    name      = "ecr-credentials-output"
    namespace = "claim-criminal-injuries-compensation-prod"
  }

  data {
    access_key_id     = "${module.cica_ecr_credentials.access_key_id}"
    secret_access_key = "${module.cica_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.cica_ecr_credentials.repo_arn}"
    repo_url          = "${module.cica_ecr_credentials.repo_url}"
  }
}
