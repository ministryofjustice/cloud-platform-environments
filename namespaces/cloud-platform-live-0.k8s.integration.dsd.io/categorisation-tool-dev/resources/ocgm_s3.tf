terraform {
  backend "s3" {}
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ocgm_offender_data_omic_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "cloudplatform"
  business-unit          = "mojdigital"
  application            = "cloud-platform-terraform-s3-bucket"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platform@digtal.justice.gov.uk"
}

resource "kubernetes_secret" "ocgm_offender_data_omic_s3_bucket" {
  metadata {
    name      = "ocgm-offender-data-omic-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.ocgm_offender_data_omic_s3_bucket.access_key_id}"
    secret_access_key = "${module.ocgm_offender_data_omic_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.ocgm_offender_data_omic_s3_bucket.bucket_arn}"
    bucket_name       = "${module.ocgm_offender_data_omic_s3_bucket.bucket_name}"
  }
}