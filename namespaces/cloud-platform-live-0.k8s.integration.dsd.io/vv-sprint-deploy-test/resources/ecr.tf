terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module vv-ecr-repo {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "vv-k8s-sprint-deploy-test"
  team_name = "test-webops"
}

resource "kubernetes_secret" "vv-ecr-repo" {
  metadata {
    name      = "ecr-repo-vv-sprint-deploy-test"
    namespace = "vv-sprint-deploy-test"
  }
  data {
    repo_url          = "${module.vv-ecr-repo.repo_url}"
    access_key_id     = "${module.vv-ecr-repo.access_key_id}"
    secret_access_key = "${module.vv-ecr-repo.secret_access_key}"
  }
}