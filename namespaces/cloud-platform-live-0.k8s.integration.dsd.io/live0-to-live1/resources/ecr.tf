/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_live0_to_live1" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "ecr-live0-to-live1"
  team_name = "${var.team_name}"
}

resource "kubernetes_secret" "sec-ecr_live0_to_live1" {
  metadata {
    name      = "ecr-live0-to-live1-migration"
    namespace = "${var.namespace}"
  }

  data {
    repo_url          = "${module.ecr_live0_to_live1.repo_url}"
    access_key_id     = "${module.ecr_live0_to_live1.access_key_id}"
    secret_access_key = "${module.ecr_live0_to_live1.secret_access_key}"
  }
}
