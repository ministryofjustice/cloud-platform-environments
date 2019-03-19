terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "vv-ecr-cred-new" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "vv-ecr-cred-new"
  team_name = "test-webops-cred"
}

resource "kubernetes_secret" "vv-ecr-cred-new" {
  metadata {
    name      = "ecr-repo-vv-myapp-new"
    namespace = "vv-myapp-dev"
  }

  data {
    repo_url          = "${module.vv-ecr-cred-new.repo_url}"
    access_key_id     = "${module.vv-ecr-cred-new.access_key_id}"
    secret_access_key = "${module.vv-ecr-cred-new.secret_access_key}"
  }
}
