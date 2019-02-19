
module "risk_offender_data_omic_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "cloudplatform"
  business-unit          = "mojdigital"
  application            = "cloud-platform-terraform-s3-bucket"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platform@digtal.justice.gov.uk"
}

module "pras_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name = "omic"
  bucket_id = "pras"
}

module "ocg_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name = "omic"
  bucket_id = "ocg"
}

module "ocgm_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name = "omic"
  bucket_id = "ocgm"
}

module "pathfinder_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name = "omic"
  bucket_id = "pathfinder"
}

module "viper_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name = "omic"
  bucket_id = "viper"
}

resource "kubernetes_secret" "viper_offender_data_omic_s3_bucket" {
  metadata {
    name      = "viper-offender-data-omic-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.risk_offender_data_omic_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_offender_data_omic_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.viper_s3_bucket.bucket_arn}"
    bucket_name       = "${module.viper_s3_bucket.bucket_name}"
  }
}

resource "kubernetes_secret" "pras_offender_data_omic_s3_bucket" {
  metadata {
    name      = "pras-offender-data-omic-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.risk_offender_data_omic_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_offender_data_omic_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.pras_s3_bucket.bucket_arn}"
    bucket_name       = "${module.pras_s3_bucket.bucket_name}"
  }
}


resource "kubernetes_secret" "ocgm_offender_data_omic_s3_bucket" {
  metadata {
    name      = "ocgm-offender-data-omic-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.risk_offender_data_omic_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_offender_data_omic_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.ocgm_s3_bucket.bucket_arn}"
    bucket_name       = "${module.ocgm_s3_bucket.bucket_name}"
  }
}

resource "kubernetes_secret" "pathfinder_offender_data_omic_s3_bucket" {
  metadata {
    name      = "pathfinder-offender-data-omic-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.risk_offender_data_omic_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_offender_data_omic_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.pathfinder_s3_bucket.bucket_arn}"
    bucket_name       = "${module.pathfinder_s3_bucket.bucket_name}"
  }
}


resource "kubernetes_secret" "ocg_offender_data_omic_s3_bucket" {
  metadata {
    name      = "ocg-offender-data-omic-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.risk_offender_data_omic_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_offender_data_omic_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.ocg_s3_bucket.bucket_arn}"
    bucket_name       = "${module.ocg_s3_bucket.bucket_name}"
  }
}