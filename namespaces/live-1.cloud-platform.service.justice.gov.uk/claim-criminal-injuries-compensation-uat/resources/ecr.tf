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
module "cica_ecr_credentials" {
  source     = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"
  repo_name  = "repo-uat"
  team_name  = "cica"
  aws_region = "eu-west-2"                                                                     # this overwrite the region from the provider defined above.
}

resource "kubernetes_secret" "ecr_repo" {
  metadata {
    name      = "cica-ecr-credentials-output"
    namespace = "claim-criminal-injuries-compensation-uat"
  }

  data {
    access_key_id     = "${module.cica_ecr_credentials.access_key_id}"
    secret_access_key = "${module.cica_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.cica_ecr_credentials.repo_arn}"
    repo_url          = "${module.cica_ecr_credentials.repo_url}"
  }
}

