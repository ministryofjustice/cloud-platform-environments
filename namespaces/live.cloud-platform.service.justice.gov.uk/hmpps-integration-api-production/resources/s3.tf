module "truststore_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london_without_default_tags
  }

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowBucketAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.api_gateway_role.arn}"
      },
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

resource "kubernetes_secret" "truststore_s3_bucket" {
  metadata {
    name      = "truststore-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.truststore_s3_bucket.access_key_id
    secret_access_key = module.truststore_s3_bucket.secret_access_key
    bucket_arn        = module.truststore_s3_bucket.bucket_arn
    bucket_name       = module.truststore_s3_bucket.bucket_name
  }
}

data "github_repository_file" "truststore" {
  repository = "ministryofjustice/hmpps-integration-api"
  file       = "temporary_certificates/production-truststore.pem"
}

resource "aws_s3_object" "truststore" {
  bucket  = module.truststore_s3_bucket.bucket_name
  key     = "production-truststore.pem"
  content = data.github_repository_file.truststore.content
}
