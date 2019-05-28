module "cccd_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.2"

  team_name              = "laa-get-paid"
  business-unit          = "legal-aid-agency"
  application            = "cccd"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd_s3_bucket" {
  metadata {
    name      = "cccd-s3-bucket"
    namespace = "cccd-staging"
  }

  data {
    access_key_id     = "${module.cccd_s3_bucket.access_key_id}"
    secret_access_key = "${module.cccd_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.cccd_s3_bucket.bucket_arn}"
    bucket_name       = "${module.cccd_s3_bucket.bucket_name}"
  }
}
