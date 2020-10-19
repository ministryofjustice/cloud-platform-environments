module "hmpps_pin_phone_monitor_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.4"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = true
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "pin-phone-data-expiry"
      expiration = [
        {
          days = 90
        },
      ]
    },
  ]

  user_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:ListBucket"
    ],
    "Resource": "$${bucket_arn}"
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:DeleteObject"
    ],
    "Resource": "$${bucket_arn}/*"
  }
]
}
EOF

}

resource "kubernetes_secret" "hmpps_pin_phone_monitor_document_s3_bucket" {
  metadata {
    name      = "hmpps-pin-phone-monitor-document-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_pin_phone_monitor_document_s3_bucket.access_key_id
    secret_access_key = module.hmpps_pin_phone_monitor_document_s3_bucket.secret_access_key
    bucket_arn        = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn
    bucket_name       = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_name
  }
}

