terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "vv-ecr-pr1" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "vv-k8s-deploy-test-app"
  team_name = "test-webops"
}

resource "kubernetes_secret" "ecr-repo-pr1" {
  metadata {
    name      = "ecr-repo-pr1-vv-myapp-dev"
    namespace = "vv-myapp-dev"
  }

  data {
    repo_url          = "${module.vv-ecr-pr1.repo_url}"
    access_key_id     = "${module.vv-ecr-pr1.access_key_id}"
    secret_access_key = "${module.vv-ecr-pr1.secret_access_key}"
  }
}
