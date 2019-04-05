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
module "cica-repo" {
  source     = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"
  repo_name  = "cica-repo"
  team_name  = "cica-team"
  aws_region = "eu-west-2"                                                                     # this overwrite the region from the provider defined above.
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-cica-compensation-uat"
    namespace = "cica-apply-for-compensation-uat"
  }

  data {
    access_key_id     = "${module.example_team_ecr_credentials.access_key_id}"
    secret_access_key = "${module.example_team_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.example_team_ecr_credentials.repo_arn}"
    repo_url          = "${module.example_team_ecr_credentials.repo_url}"
  }
}

