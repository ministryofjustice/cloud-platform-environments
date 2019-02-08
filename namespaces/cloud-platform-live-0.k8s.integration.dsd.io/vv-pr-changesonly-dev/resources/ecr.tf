terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "vv-ecr-pr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "vv-k8s-deploy-test-app"
  team_name = "test-webops"
}

resource "kubernetes_secret" "ecr-repo-test" {
  metadata {
    name      = "ecr-repo-pr-vv-myapp-dev"
    namespace = "vv-pr-changesonly-dev"
  }

  data {
    repo_url          = "${module.vv-ecr-pr.repo_url}"
    access_key_id     = "${module.vv-ecr-pr.access_key_id}"
    secret_access_key = "${module.vv-ecr-pr.secret_access_key}"
  }
}
