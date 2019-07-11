module "risk_profiler_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.0"
  team_name              = "${var.team_name}"
  acl                    = "private"
  versioning             = false
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
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

resource "kubernetes_secret" "risk_profiler_s3_bucket" {
  metadata {
    name      = "risk-profiler-s3-bucket-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.risk_profiler_s3_bucket.access_key_id}"
    secret_access_key = "${module.risk_profiler_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.risk_profiler_s3_bucket.bucket_arn}"
    bucket_name       = "${module.risk_profiler_s3_bucket.bucket_name}"
  }
}
