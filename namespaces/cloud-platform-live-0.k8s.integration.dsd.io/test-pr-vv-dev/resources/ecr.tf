terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo-test" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"

  team_name = "test-webops"
  repo_name = "test-webops"
}

resource "kubernetes_secret" "ecr-repo-test" {
  metadata {
    name      = "ecr-repo-test-webops"
    namespace = "test-pr-vv-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-test.repo_url}"
    access_key_id     = "${module.ecr-repo-test.access_key_id}"
    secret_access_key = "${module.ecr-repo-test.secret_access_key}"
  }
}
