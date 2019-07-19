/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_fee_caclulator_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "${var.repo_name}"
  team_name = "${var.team_name}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "laa_fee_caclulator_team_ecr_credentials" {
  metadata {
    name      = "laa-fee-caclulator-team-ecr-credentials-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.laa_fee_caclulator_team_ecr_credentials.access_key_id}"
    secret_access_key = "${module.laa_fee_caclulator_team_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.laa_fee_caclulator_team_ecr_credentials.repo_arn}"
    repo_url          = "${module.laa_fee_caclulator_team_ecr_credentials.repo_url}"
  }
}
