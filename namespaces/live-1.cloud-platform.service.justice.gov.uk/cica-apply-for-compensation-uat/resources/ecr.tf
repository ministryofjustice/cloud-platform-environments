/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "cica-repo" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "cica"
  team_name = "cica"

  providers = {
    aws = "aws.london"
  } # this overwrite the region from the provider defined above.
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-cica-compensation-uat"
    namespace = "cica-apply-for-compensation-uat"
  }

  data {
    access_key_id     = "${module.cica-repo.access_key_id}"
    secret_access_key = "${module.cica-repo.secret_access_key}"
    repo_url          = "${module.cica-repo.repo_url}"
  }
}
