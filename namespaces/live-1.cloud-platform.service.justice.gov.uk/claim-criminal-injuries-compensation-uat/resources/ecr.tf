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
  source     = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=$
  repo_name  = "cica-repo"
  team_name  = "cica"
  aws_region = "eu-west-2"                                                                $
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-claim-criminal-injuries-compensation-uat"
    namespace = "claim-criminal-injuries-compensation-uat"
  }

  data {
    access_key_id     = "${module.cica-repo.access_key_id}"
    secret_access_key = "${module.cica-repo.secret_access_key}"
    repo_url          = "${module.cica-repo.repo_url}"
  }
}

