terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=master"

  team_name = "cloud-platform"
  repo_name = "support-labelling-webhook"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-support-labelling-webhook"
    namespace = "support-labelling-webhook"
  }

  data {
    repo_url          = "${module.ecr-repo.repo_url}"
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
  }
}
