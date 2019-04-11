terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"

  team_name = "laa-get-access"
  repo_name = "laa-legal-adviser-api"
}

resource "kubernetes_secret" "ecr-repo-api" {
  metadata {
    name      = "ecr-repo-laa-legal-adviser-api"
    namespace = "laa-legal-adviser-api-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-api.repo_url}"
    access_key_id     = "${module.ecr-repo-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-api.secret_access_key}"
  }
}
