terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "vv-test-comment" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "vv-k8s-deploy-comment"
  team_name = "test-webops-comment"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-vv-myapp-dev-comm"
    namespace = "vv-myapp-dev-comm"
  }

  data {
    repo_url          = "${module.vv-test-comment.repo_url}"
    access_key_id     = "${module.vv-test-comment.access_key_id}"
    secret_access_key = "${module.vv-test-comment.secret_access_key}"
  }
}
