terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "authorized-keys" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "cloudplatform"
  acl                    = "private"
  versioning             = false
  business-unit          = "mojdigital"
  application            = "cloud-platform-authorized-keys"
  is-production          = "true"
  environment-name       = "production"
  infrastructure-support = "platforms@digital.justice.gov.uk"
}

resource "kubernetes_secret" "s3_bucket_credentials" {
  metadata {
    name      = "s3-bucket-authorized-keys"
    namespace = "authorized-keys-provider"
  }

  data {
    bucket_name       = "${module.authorized-keys.bucket_name}"
    access_key_id     = "${module.authorized-keys.access_key_id}"
    secret_access_key = "${module.authorized-keys.secret_access_key}"
  }
}
