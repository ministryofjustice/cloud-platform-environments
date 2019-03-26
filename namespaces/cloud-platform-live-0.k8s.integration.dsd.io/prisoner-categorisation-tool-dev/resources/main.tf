terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "prisoner-categorisation-tool"
  repo_name = "prisoner-categorisation-tool-ruby"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-prisoner-categorisation-tool-dev"
    namespace = "prisoner-categorisation-tool-dev"
  }

  data {
    repo_url          = "${module.ecr-repo.repo_url}"
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
  }
}
