terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

module "cbo_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"
  repo_name = "claim-for-crown-court-defence"
  team_name = "crime-billing-online"
}

resource "kubernetes_secret" "cbo_ecr_credentials" {
  metadata {
    name      = "cbo-credentials-output"
    namespace = "cccd-dev"
  }

  data {
    access_key_id     = "${module.cbo_ecr_credentials.access_key_id}"
    secret_access_key = "${module.cbo_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.cbo_ecr_credentials.repo_arn}"
    repo_url          = "${module.cbo_ecr_credentials.repo_url}"
  }
}
