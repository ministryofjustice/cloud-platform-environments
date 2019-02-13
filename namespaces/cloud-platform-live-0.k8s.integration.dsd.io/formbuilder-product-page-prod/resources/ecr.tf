terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "formbuilder_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.0"
  repo_name = "formBuilder-product-page"
  team_name = "formbuilder"
}

resource "kubernetes_secret" "formbuilder_ecr_credentials" {
  metadata {
    name      = "formbuilder_ecr_credentials_output"
    namespace = "formbuilder-product-page-prod"
  }

  data {
    access_key        = "${module.formbuilder_ecr_credentials.access_key_id}"
    secret_access_key = "${module.formbuilder_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.formbuilder_ecr_credentials.repo_arn}"
    repo_url          = "${module.formbuilder_ecr_credentials.repo_url}"
  }
}
