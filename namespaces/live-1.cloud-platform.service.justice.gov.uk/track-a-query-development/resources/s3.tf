################################################################################
# Track a Query (Correspondence Tool Staff)
# S3 Bucket for file uploads
#################################################################################

module "track_a_query_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.3"

  team_name              = "correspondence"
  business-unit          = "Central Digital"
  application            = "track-a-query"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "mohammed.seedat@digtal.justice.gov.uk"

  user_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        "Resource": [
          "$${bucket_arn}",
          "arn:aws:s3:::correspondence-staff-case-uploads-dev"
        ]
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "$${bucket_arn}/*",
          "arn:aws:s3:::correspondence-staff-case-uploads-dev/*"
        ]
      }
    ]
  }
  EOF

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "track_a_query_s3" {
  metadata {
    name      = "track-a-query-s3-output"
    namespace = "track-a-query-development"
  }

  data {
    access_key_id     = "${module.track_a_query_s3.access_key_id}"
    secret_access_key = "${module.track_a_query_s3.secret_access_key}"
    bucket_arn        = "${module.track_a_query_s3.bucket_arn}"
    bucket_name       = "${module.track_a_query_s3.bucket_name}"
  }
}
