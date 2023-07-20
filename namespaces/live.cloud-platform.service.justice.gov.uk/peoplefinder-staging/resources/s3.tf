################################################################################
# People Finder
# S3 Bucket for file uploads
#################################################################################

module "peoplefinder_s3" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "POST", "PUT"]
      allowed_origins = ["https://staging.peoplefinder.service.gov.uk"]
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
      "arn:aws:s3:::peoplefinder-staging-assets"
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
      "arn:aws:s3:::peoplefinder-staging-assets/*"
    ]
  }
]
}
EOF

}

resource "kubernetes_secret" "peoplefinder_s3" {
  metadata {
    name      = "peoplefinder-s3-output"
    namespace = "peoplefinder-staging"
  }

  data = {
    bucket_name       = module.peoplefinder_s3.bucket_name
  }
}
