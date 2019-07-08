module "live0_to_live1_ecr_cred" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "live0-to-live1"
  team_name = "webops-cp"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "live0_to_live1_ecr_cred" {
  metadata {
    name      = "live0-to-live1-ecr-credentials-output"
    namespace = "live0-to-live1"
  }

  data {
    access_key_id     = "${module.live0_to_live1_ecr_cred.access_key_id}"
    secret_access_key = "${module.live0_to_live1_ecr_cred.secret_access_key}"
    repo_arn          = "${module.live0_to_live1_ecr_cred.repo_arn}"
    repo_url          = "${module.live0_to_live1_ecr_cred.repo_url}"
  }
}
