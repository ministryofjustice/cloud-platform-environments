/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "cccd_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.3"

  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd_s3_bucket" {
  metadata {
    name      = "cccd-s3-bucket"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.cccd_s3_bucket.access_key_id}"
    secret_access_key = "${module.cccd_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.cccd_s3_bucket.bucket_arn}"
    bucket_name       = "${module.cccd_s3_bucket.bucket_name}"
  }
}
