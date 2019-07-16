module "risk_profiler_digcat_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.0"
  team_name              = "digcat"
  acl                    = "private"
  versioning             = false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "false"
  environment-name       = "categorisation-tool-dev"
  infrastructure-support = "michael.willis@digtal.justice.gov.uk"
  aws-s3-region          = "eu-west-2"
}

module "viper_digcat_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.0"

  team_name              = "digcat"
  acl                    = "private"
  versioning             = false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "false"
  environment-name       = "categorisation-tool-dev"
  infrastructure-support = "michael.willis@digtal.justice.gov.uk"
  aws-s3-region          = "eu-west-2"

  bucket_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DelegateS3Access",
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::754256621582:user/system/s3-bucket-user/Digital-Prison-Services/s3-bucket-user-33fed4c202e82791a7a0bf9398c9f1fc"},
            "Action": ["s3:ListBucket","s3:GetObject"],
            "Resource": [
                "$${bucket_arn}/*",
                "$${bucket_arn}"
            ]
        }
    ]
}
EOF
}

resource "kubernetes_secret" "viper_digcat_s3_bucket" {
  metadata {
    name      = "viper-digcat-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.viper_digcat_s3_bucket.access_key_id}"
    secret_access_key = "${module.viper_digcat_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.viper_digcat_s3_bucket.bucket_arn}"
    bucket_name       = "${module.viper_digcat_s3_bucket.bucket_name}"
  }
}

resource "kubernetes_secret" "risk_profiler_digcat_s3_bucket" {
  metadata {
    name      = "risk-profiler-digcat-s3-bucket-output"
    namespace = "categorisation-tool-dev"
  }

  data {
    access_key_id     = "${module.risk_profiler_digcat_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_profiler_digcat_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.risk_profiler_digcat_s3_bucket.bucket_arn}"
    bucket_name       = "${module.risk_profiler_digcat_s3_bucket.bucket_name}"
  }
}
