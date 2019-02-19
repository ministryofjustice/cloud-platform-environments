module "authorized-keys" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "vv-myapp-dev"
  business-unit          = "test"
  application            = "vv-myapp-dev"
  is-production          = "false"
  environment-name       = "test"
  infrastructure-support = "apply@digtal.justice.gov.uk"
}

resource "kubernetes_secret" "vv-myapp-dev-s3-credentials" {
  metadata {
    name      = "vv-myapp-dev-s3-instance-output"
    namespace = "vv-myapp-dev"
  }

  data {
    bucket_name       = "${module.authorized-keys.bucket_name}"
    access_key_id     = "${module.authorized-keys.access_key_id}"
    secret_access_key = "${module.authorized-keys.secret_access_key}"
  }
}
