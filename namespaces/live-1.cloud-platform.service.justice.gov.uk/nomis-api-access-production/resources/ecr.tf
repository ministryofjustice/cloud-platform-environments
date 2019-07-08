module "nomis-api-access_ecr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "${var.namespace}"
  team_name = "digital-prison-services"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "nomis-api-access_ecr" {
  metadata {
    name      = "nomis-api-access-ecr-credentials-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.nomis-api-access_ecr.access_key_id}"
    secret_access_key = "${module.nomis-api-access_ecr.secret_access_key}"
    repo_arn          = "${module.nomis-api-access_ecr.repo_arn}"
    repo_url          = "${module.nomis-api-access_ecr.repo_url}"
  }
}
