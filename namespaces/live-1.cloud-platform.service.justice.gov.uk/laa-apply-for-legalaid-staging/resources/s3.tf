module "authorized-keys" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.2"

  team_name              = "apply-for-legal-aid"
  acl                    = "private"
  business-unit          = "laa"
  application            = "laa-apply-for-legal-aid"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "apply@digtal.justice.gov.uk"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "apply-for-legal-aid-s3-credentials" {
  metadata {
    name      = "apply-for-legal-aid-s3-instance-output"
    namespace = "laa-apply-for-legalaid-staging"
  }

  data {
    bucket_name       = "${module.authorized-keys.bucket_name}"
    access_key_id     = "${module.authorized-keys.access_key_id}"
    secret_access_key = "${module.authorized-keys.secret_access_key}"
  }
}
