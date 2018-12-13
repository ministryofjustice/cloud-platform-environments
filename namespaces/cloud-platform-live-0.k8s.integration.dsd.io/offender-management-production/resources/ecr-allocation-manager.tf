terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo-allocation-manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "offender-management"
  repo_name = "offender-management-allocation-manager"
}

resource "kubernetes_secret" "ecr-repo-allocation-manager" {
  metadata {
    name      = "offender-management-allocation-manager"
    namespace = "offender-management-production"
  }

  data {
    repo_url          = "${module.ecr-repo-allocation-manager.repo_url}"
    access_key_id     = "${module.ecr-repo-allocation-manager.access_key_id}"
    secret_access_key = "${module.ecr-repo-allocation-manager.secret_access_key}"
  }
}
