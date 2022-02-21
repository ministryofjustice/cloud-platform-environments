module "analytical_platform_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
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
    "Principal": {
          "AWS": "${module.analytical-platform.aws_iam_role_arn}
      },
    "Action": [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ],
    "Resource": "$${bucket_arn}/*"
  }
]
}
EOF

}

resource "kubernetes_secret" "analytical_platform_s3_bucket" {
  metadata {
    name      = "analytical-platform-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.analytical_platform_s3_bucket.access_key_id
    secret_access_key = module.analytical_platform_s3_bucket.secret_access_key
    bucket_arn        = module.analytical_platform_s3_bucket.bucket_arn
    bucket_name       = module.analytical_platform_s3_bucket.bucket_name
  }
}

