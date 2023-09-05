module "cccd_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.0.0"

  team_name              = "laa-get-paid"
  business_unit          = "legal-aid-agency"
  application            = "cccd"
  is_production          = "false"
  environment_name       = "dev"
  infrastructure_support = "crowncourtdefence@digital.justice.gov.uk"
  namespace              = var.namespace

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
      "arn:aws:s3:::adp-dev-documents"
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
      "arn:aws:s3:::adp-dev-documents/*"
    ]
  }
]
}
EOF

}

resource "kubernetes_secret" "cccd_s3_bucket" {
  metadata {
    name      = "cccd-s3-bucket"
    namespace = "cccd-dev-lgfs"
  }

  data = {
    bucket_arn  = module.cccd_s3_bucket.bucket_arn
    bucket_name = module.cccd_s3_bucket.bucket_name
  }
}
