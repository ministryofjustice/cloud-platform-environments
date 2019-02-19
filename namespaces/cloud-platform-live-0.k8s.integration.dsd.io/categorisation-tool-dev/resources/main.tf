terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"

  team_name = "omic"
  repo_name = "categorisation-tool"
}

module "offender-risk-profiler-ecr-repo" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "offender-risk-profiler"
  team_name = "omic"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-categorisation-tool"
    namespace = "categorisation-tool-dev"
  }

  data {
    repo_url          = "${module.ecr-repo.repo_url}"
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
  }
}

resource "kubernetes_secret" "offender-risk-profiler-ecr-repo" {
  metadata {
    name      = "offender-risk-profiler-ecr-repo"
    namespace = "categorisation-tool-dev"
  }

  data {
    repo_url          = "${module.offender-risk-profiler-ecr-repo.repo_url}"
    access_key_id     = "${module.offender-risk-profiler-ecr-repo.access_key_id}"
    secret_access_key = "${module.offender-risk-profiler-ecr-repo.secret_access_key}"
  }
}

