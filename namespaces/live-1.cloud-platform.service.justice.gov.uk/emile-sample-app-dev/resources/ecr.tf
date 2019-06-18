terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "emile_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "emile-sample-app"
  team_name = "formbuilder-dev"
}

resource "kubernetes_secret" "ecr_repo" {
  metadata {
    name      = "emile-ecr-credentials-output"
    namespace = "emile-sample-app-dev"
  }

  data {
    access_key_id     = "${module.emile_ecr_credentials.access_key_id}"
    secret_access_key = "${module.emile_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.emile_ecr_credentials.repo_arn}"
    repo_url          = "${module.emile_ecr_credentials.repo_url}"
  }
}
