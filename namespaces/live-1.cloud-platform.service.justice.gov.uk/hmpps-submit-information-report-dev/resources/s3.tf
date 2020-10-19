module "hmpps_submit_information_report_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  infrastructure-support = var.infrastructure-support

  is-production    = var.is-production
  environment-name = var.environment-name
  namespace        = var.namespace

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_submit_information_report_s3_bucket" {
  metadata {
    name      = "hmpps-submit-information-report-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_submit_information_report_s3_bucket.access_key_id
    secret_access_key = module.hmpps_submit_information_report_s3_bucket.secret_access_key
    bucket_arn        = module.hmpps_submit_information_report_s3_bucket.bucket_arn
    bucket_name       = module.hmpps_submit_information_report_s3_bucket.bucket_name
  }
}
