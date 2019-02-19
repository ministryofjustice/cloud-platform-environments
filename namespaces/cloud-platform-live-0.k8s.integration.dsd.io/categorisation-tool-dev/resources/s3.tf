
module "pras_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"
  team_name              = "omic"
  acl                    = "private"
  versioning             =  false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "false"
  environment-name       = "categorisation-tool-dev"
  infrastructure-support = "feedback@digtal.justice.gov.uk"
}

module "ocg_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "omic"
  acl                    = "private"
  versioning             =  false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "false"
  environment-name       = "categorisation-tool-dev"
  infrastructure-support = "feedback@digtal.justice.gov.uk"
}

module "ocgm_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "omic"
  acl                    = "private"
  versioning             =  false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "false"
  environment-name       = "categorisation-tool-dev"
  infrastructure-support = "feedback@digtal.justice.gov.uk"
}

module "pathfinder_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "omic"
  acl                    = "private"
  versioning             =  false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "false"
  environment-name       = "categorisation-tool-dev"
  infrastructure-support = "feedback@digtal.justice.gov.uk"
}

module "viper_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

  team_name              = "omic"
  acl                    = "private"
  versioning             =  false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "false"
  environment-name       = "categorisation-tool-dev"
  infrastructure-support = "feedback@digtal.justice.gov.uk"
}

resource "kubernetes_secret" "viper_offender_data_omic_s3_bucket" {
  metadata {
    name      = "viper-offender-data-omic-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.viper_s3_bucket.access_key_id}"
    secret_access_key = "${module.viper_s3_bucket.secret_access_key}"
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
    access_key_id     = "${module.pras_s3_bucket.access_key_id}"
    secret_access_key = "${module.pras_s3_bucket.secret_access_key}"
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
    access_key_id     = "${module.ocgm_s3_bucket.access_key_id}"
    secret_access_key = "${module.ocgm_s3_bucket.secret_access_key}"
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
    access_key_id     = "${module.pathfinder_s3_bucket.access_key_id}"
    secret_access_key = "${module.pathfinder_s3_bucket.secret_access_key}"
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
    access_key_id     = "${module.ocg_s3_bucket.access_key_id}"
    secret_access_key = "${module.ocg_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.ocg_s3_bucket.bucket_arn}"
    bucket_name       = "${module.ocg_s3_bucket.bucket_name}"
  }
}