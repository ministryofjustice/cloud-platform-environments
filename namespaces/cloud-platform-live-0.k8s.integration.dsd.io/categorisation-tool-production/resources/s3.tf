module "risk_profiler_digcat_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.0"
  team_name              = "digcat"
  acl                    = "private"
  versioning             = false
  business-unit          = "hmpps"
  application            = "offender-risk-profiler"
  is-production          = "true"
  environment-name       = "categorisation-tool-production"
  infrastructure-support = "michael.willis@digtal.justice.gov.uk"
  aws-s3-region          = "eu-west-2"

  bucket_policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::593291632749:role/airflow_viper_to_external"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "$${bucket_arn}/viper/*"
            ]
        }
    ]
}
EOF
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
