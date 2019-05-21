module "dps_ecr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.3"
  repo_name = "${var.namespace}"
  team_name = "digital-prison-services"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "dps_ecr" {
  metadata {
    name      = "dps-ecr-credentials-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.dps_ecr.access_key_id}"
    secret_access_key = "${module.dps_ecr.secret_access_key}"
    repo_arn          = "${module.dps_ecr.repo_arn}"
    repo_url          = "${module.dps_ecr.repo_url}"
  }
}
