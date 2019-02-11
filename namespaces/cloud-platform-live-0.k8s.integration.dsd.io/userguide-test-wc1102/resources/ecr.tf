terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "vv-ecr-wc-1102" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "vv-ecr-wc-1102"
  team_name = "test-webops"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-vv-ecr-wc-1102"
    namespace = "userguide-test-wc1102"
  }

  data {
    repo_url          = "${module.vv-ecr-wc-1102.repo_url}"
    access_key_id     = "${module.vv-ecr-wc-1102.access_key_id}"
    secret_access_key = "${module.vv-ecr-wc-1102.secret_access_key}"
  }
}
