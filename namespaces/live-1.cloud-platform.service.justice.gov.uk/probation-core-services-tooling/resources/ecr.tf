/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "hmpps-core-services_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "digital-probation-tooling"
  team_name = "hmpps-core-services"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "hmpps-core-services_ecr_credentials" {
  metadata {
    name      = "hmpps-core-services-ecr-credentials-output"
    namespace = "probation-core-services-tooling"
  }

  data {
    access_key_id     = "${module.hmpps-core-services_ecr_credentials.access_key_id}"
    secret_access_key = "${module.hmpps-core-services_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.hmpps-core-services_ecr_credentials.repo_arn}"
    repo_url          = "${module.hmpps-core-services_ecr_credentials.repo_url}"
  }
}
