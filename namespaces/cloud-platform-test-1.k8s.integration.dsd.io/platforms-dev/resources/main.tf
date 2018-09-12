terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "example_team_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=master"

  team_name              = "cloud-platform"
  acl                    = "private"
  versioning             = false
  business-unit          = "mojdigital"
  application            = "pipeline-example"
  is-production          = "false"
  environment-name       = "dev"
  infrastructure-support = "platform@digtal.justice.gov.uk"
}

resource "kubernetes_secret" "example_s3_bucket_credentials" {
  metadata {
    name      = "s3-bucket-example"
    namespace = "platforms-dev"
  }

  data {
    bucket_name       = "${module.example_team_s3.bucket_name}"
    access_key_id     = "${module.example_team_s3.access_key_id}"
    secret_access_key = "${module.example_team_s3.secret_access_key}"
  }
}
