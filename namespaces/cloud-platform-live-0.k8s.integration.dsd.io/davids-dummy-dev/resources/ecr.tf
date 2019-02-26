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
module "davids_dummy_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "davids-dummy-app"
  team_name = "davids-dummy-team"
}

resource "kubernetes_secret" "davids_dummy_ecr_credentials" {
  metadata {
    name      = "davids-dummy-ecr-credentials-output"
    namespace = "davids-dummy-dev"
  }

  data {
    access_key_id     = "${module.davids_dummy_ecr_credentials.access_key_id}"
    secret_access_key = "${module.davids_dummy_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.davids_dummy_ecr_credentials.repo_arn}"
    repo_url          = "${module.davids_dummy_ecr_credentials.repo_url}"
  }
}
