terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"

  team_name = "omic"
  repo_name = "whereabouts-api"
}

module "whereabouts-api-postgres-ecr-repo" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"
  team_name = "omic"
  repo_name = "whereabouts-api-postgres"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-whereabouts-api"
    namespace = "whereabouts-dev"
  }

  data {
    repo_url          = "${module.ecr-repo.repo_url}"
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
  }
}

resource "kubernetes_secret" "whereabouts-api-postgres-ecr-repo" {
  metadata {
    name      = "whereabouts-api-postgres-ecr-repo"
    namespace = "whereabouts-dev"
  }

  data {
    repo_url          = "${module.whereabouts-api-postgres-ecr-repo.repo_url}"
    access_key_id     = "${module.whereabouts-api-postgres-ecr-repo.access_key_id}"
    secret_access_key = "${module.whereabouts-api-postgres-ecr-repo.secret_access_key}"
  }
}
