module "cica-test-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.email
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "cica-test-bucket" {
  metadata {
    name      = "cica-test-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.cica-test-bucket.bucket_arn
    bucket_name = module.cica-test-bucket.bucket_name
  }
}

module "cica-letter-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.email
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  bucket_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "cica-letter-bucket-access-policy",
    "Statement": [
      {
        "Sid": "cica-letter-bucket-allow-letter-service",
        "Effect": "Allow",
        "Principal": { "AWS": "${module.irsa-letter-service.role_arn}" },
        "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ],
        "Resource": [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      },
      {
        "Sid": "cica-letter-bucket-allow-tempus-broker",
        "Effect": "Allow",
        "Principal": {"AWS": "${data.aws_ssm_parameter.cica_dev_account_id.value}"},
        "Action": [
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:AbortMultipartUpload"
        ],
        "Resource": "$${bucket_arn}/*"
      },
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ],
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  }
  EOF

}

resource "kubernetes_secret" "cica-letter-bucket" {
  metadata {
    name      = "cica-letter-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.cica-letter-bucket.bucket_arn
    bucket_name = module.cica-letter-bucket.bucket_name
  }
}
