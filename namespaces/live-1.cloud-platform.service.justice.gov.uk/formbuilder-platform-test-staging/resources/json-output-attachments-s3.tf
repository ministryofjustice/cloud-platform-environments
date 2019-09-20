module "json-output-attachments-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.3"

  team_name              = "${var.team_name}"
  acl                    = "private"
  versioning             = false
  business-unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"

  providers = {
    aws = "aws.london"
  }

  user_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject"
    ],
    "Resource": "$${bucket_arn}/*"
  }
]
}
EOF

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-7d"
      prefix                                 = "7d/"
      abort_incomplete_multipart_upload_days = 7

      expiration = [
        {
          days = 7
        },
      ]

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "json-output-attachments-s3-bucket" {
  metadata {
    name      = "json-output-attachments-s3-bucket-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data {
    access_key_id     = "${module.json-output-attachments-s3-bucket.access_key_id}"
    bucket_arn        = "${module.json-output-attachments-s3-bucket.bucket_arn}"
    bucket_name       = "${module.json-output-attachments-s3-bucket.bucket_name}"
    secret_access_key = "${module.json-output-attachments-s3-bucket.secret_access_key}"
  }
}
