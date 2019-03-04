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
module "jhackett-dso-service" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "jhackett-dso"
  team_name = "dso"
}

resource "kubernetes_secret" "example_team_ecr_credentials" {
  metadata {
    name      = "jhackett-dso-ecr-credentials-output"
    namespace = "jhackett-dso"
  }

  data {
    access_key_id     = "${module.jhackett-dso-service.access_key_id}"
    secret_access_key = "${module.jhackett-dso-service.secret_access_key}"
    repo_arn          = "${module.jhackett-dso-service.repo_arn}"
    repo_url          = "${module.jhackett-dso-service.repo_url}"
  }
}
