terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "new-ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"

  team_name = "new-test-webops"
  repo_name = "new-test-webops"
}

resource "kubernetes_secret" "new-ecr-repo" {
  metadata {
    name      = "new-ecr-repo-test-webops"
    namespace = "vv-sprint-deploy-test"
  }

  data {
    repo_url          = "${module.new-ecr-repo.repo_url}"
    access_key_id     = "${module.new-ecr-repo.access_key_id}"
    secret_access_key = "${module.new-ecr-repo.secret_access_key}"
  }
}
