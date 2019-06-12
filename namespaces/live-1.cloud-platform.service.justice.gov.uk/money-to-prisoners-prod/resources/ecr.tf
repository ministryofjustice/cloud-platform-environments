# https://github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials

module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  providers = {
    aws = "aws.london"
  }

  team_name = "${var.team_name}"
  repo_name = "${var.application}"
}

resource "kubernetes_secret" "ecr" {
  metadata {
    name      = "ecr"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.ecr.access_key_id}"
    secret_access_key = "${module.ecr.secret_access_key}"
    repo_arn          = "${module.ecr.repo_arn}"
    repo_url          = "${module.ecr.repo_url}"
  }
}
