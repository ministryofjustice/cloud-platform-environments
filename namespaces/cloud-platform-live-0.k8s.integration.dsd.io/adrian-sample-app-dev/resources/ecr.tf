terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "adrian_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "adrian-sample-app"
  team_name = "laa-developers"
}

resource "kubernetes_secret" "ecr_repo" {
  metadata {
    name      = "adrian-ecr-credentials-output"
    namespace = "adrian-sample-app-dev"
  }

  data {
    access_key_id     = "${module.adrian_ecr_credentials.access_key_id}"
    secret_access_key = "${module.adrian_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.adrian_ecr_credentials.repo_arn}"
    repo_url          = "${module.adrian_ecr_credentials.repo_url}"
  }
}
