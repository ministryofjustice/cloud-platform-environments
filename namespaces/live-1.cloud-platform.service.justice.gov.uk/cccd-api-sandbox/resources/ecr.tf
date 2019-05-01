module "cbo_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.2"
  repo_name = "cccd"
  team_name = "laa-get-paid"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cbo_ecr_credentials" {
  metadata {
    name      = "cbo-credentials-output"
    namespace = "cccd-api-sandbox"
  }

  data {
    access_key_id     = "${module.cbo_ecr_credentials.access_key_id}"
    secret_access_key = "${module.cbo_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.cbo_ecr_credentials.repo_arn}"
    repo_url          = "${module.cbo_ecr_credentials.repo_url}"
  }
}
