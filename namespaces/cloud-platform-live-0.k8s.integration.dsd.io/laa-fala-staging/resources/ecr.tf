terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo-laa-fala-webapp" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "laa-get-access"
  repo_name = "laa-fala-webapp"
}

resource "kubernetes_secret" "ecr-repo-laa-fala-webapp" {
  metadata {
    name      = "ecr-repo-laa-fala-webapp"
    namespace = "laa-fala-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-laa-fala-webapp.repo_url}"
    access_key_id     = "${module.ecr-repo-laa-fala-webapp.access_key_id}"
    secret_access_key = "${module.ecr-repo-laa-fala-webapp.secret_access_key}"
  }
}

module "ecr-repo-laa-fala-nginx" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "laa-get-access"
  repo_name = "laa-fala-nginx"
}

resource "kubernetes_secret" "ecr-repo-laa-fala-nginx" {
  metadata {
    name      = "ecr-repo-laa-fala-nginx"
    namespace = "laa-fala-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-laa-fala-nginx.repo_url}"
    access_key_id     = "${module.ecr-repo-laa-fala-nginx.access_key_id}"
    secret_access_key = "${module.ecr-repo-laa-fala-nginx.secret_access_key}"
  }
}
