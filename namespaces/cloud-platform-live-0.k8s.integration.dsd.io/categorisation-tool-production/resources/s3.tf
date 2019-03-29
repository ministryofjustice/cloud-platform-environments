module "risk_profiler_digcat_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=2.0"
  team_name              = "digcat"
  acl                    = "private"
  versioning             = false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "true"
  environment-name       = "categorisation-tool-production"
  infrastructure-support = "michael.willis@digtal.justice.gov.uk"
  aws-s3-region          = "eu-west-2"
}

resource "kubernetes_secret" "risk_profiler_digcat_s3_bucket" {
  metadata {
    name      = "risk-profiler-digcat-s3-bucket-output"
    namespace = "categorisation-tool-production"
  }

  data {
    access_key_id     = "${module.risk_profiler_digcat_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_profiler_digcat_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.risk_profiler_digcat_s3_bucket.bucket_arn}"
    bucket_name       = "${module.risk_profiler_digcat_s3_bucket.bucket_name}"
  }
}
