terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "nickp-test-dev"
  team_name = "tactical-products"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "nickp-test-dev-ecr-repo"
    namespace = "nickp-test-dev"
  }

  data {
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
    repo_arn          = "${module.ecr-repo.repo_arn}"
    repo_url          = "${module.ecr-repo.repo_url}"
  }
}
