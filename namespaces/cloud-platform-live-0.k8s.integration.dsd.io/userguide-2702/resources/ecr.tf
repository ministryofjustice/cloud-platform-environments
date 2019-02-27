terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "userguide-2702" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "userguide-2708"
  team_name = "test-webops"
}

resource "kubernetes_secret" "sec-userguide-2702" {
  metadata {
    name      = "ecr-repo-vv-myapp-dev"
    namespace = "vv-myapp-dev"
  }

  data {
    repo_url          = "${module.userguide-2702.repo_url}"
    access_key_id     = "${module.userguide-2702.access_key_id}"
    secret_access_key = "${module.userguide-2702.secret_access_key}"
  }
}
