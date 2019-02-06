terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "tactital-products-mt_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "mat-demo"
  team_name = "tactital-products-mt"
}

resource "kubernetes_secret" "tactital-products-mt_ecr_credentials" {
  metadata {
    name      = "tactital-products-mt-ecr-credentials-output"
    namespace = "matt-demo"
  }

  data {
    access_key_id     = "${module.tactital-products-mt_ecr_credentials.access_key_id}"
    secret_access_key = "${module.tactital-products-mt_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.tactital-products-mt_ecr_credentials.repo_arn}"
    repo_url          = "${module.tactital-products-mt_ecr_credentials.repo_url}"
  }
}
