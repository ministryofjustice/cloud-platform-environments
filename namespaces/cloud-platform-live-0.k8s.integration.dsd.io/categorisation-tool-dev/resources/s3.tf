module "risk_profiler_digcat_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=2.0"
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=bucket_policy"

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
  "Version":"2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::429061350814:user/MichaelWillis"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::cloud-platform-6b85ed6aad3c653f796ad9b306670945/*"
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
