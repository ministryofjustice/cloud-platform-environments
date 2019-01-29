terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "vv-ecr-sprint-deploy" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "vv-k8s-sprint-deploy-test"
  team_name = "test-webops"
}

resource "kubernetes_secret" "example_team_ecr_credentials" {
  metadata {
    name      = "ecr-repo-vv-sprint-deploy-test"
    namespace = "vv-sprint-deploy-test"
  }

  data {
    access_key_id     = "${module.example_team_ecr_credentials.access_key_id}"
    secret_access_key = "${module.example_team_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.example_team_ecr_credentials.repo_arn}"
    repo_url          = "${module.example_team_ecr_credentials.repo_url}"
  }
}