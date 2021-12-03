################################################################################
# People Finder
# S3 Bucket for file uploads
#################################################################################

module "peoplefinder_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7"

  team_name              = "peoplefinder"
  business-unit          = "Central Digital"
  application            = "peoplefinder"
  is-production          = "true"
  environment-name       = "production"
  infrastructure-support = "people-finder-support@digital.justice.gov.uk"

  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "POST", "PUT"]
      allowed_origins = ["https://peoplefinder.service.gov.uk", "https://peoplefinder-production.apps.live-1.cloud-platform.service.justice.gov.uk"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["Authorization"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
  ]
  namespace = var.namespace

  providers = {
    aws = aws.london
  }

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
      "arn:aws:s3:::peoplefinder-production-assets"
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
      "arn:aws:s3:::peoplefinder-production-assets/*"
    ]
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ],
    "Resource": [
      "$${bucket_arn}",
      "arn:aws:s3:::people-finder-production"
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
      "arn:aws:s3:::people-finder-production/*"
    ]
  }
]
}
EOF

}

resource "kubernetes_secret" "peoplefinder_s3" {
  metadata {
    name      = "peoplefinder-s3-output"
    namespace = "peoplefinder-production"
  }

  data = {
    access_key_id     = module.peoplefinder_s3.access_key_id
    secret_access_key = module.peoplefinder_s3.secret_access_key
    bucket_arn        = module.peoplefinder_s3.bucket_arn
    bucket_name       = module.peoplefinder_s3.bucket_name
  }
}
