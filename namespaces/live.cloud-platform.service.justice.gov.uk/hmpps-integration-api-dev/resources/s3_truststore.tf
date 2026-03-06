module "truststore_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = true

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

data "kubernetes_secret" "truststore" {
  metadata {
    name      = "mutual-tls-auth"
    namespace = var.namespace
  }
}

resource "aws_s3_object" "truststore" {
  bucket  = module.truststore_s3_bucket.bucket_name
  key     = "dev-truststore.pem"
  content = data.kubernetes_secret.truststore.data["truststore-public-key"]
}

module "certificate_backup" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  bucket_name            = "${var.namespace}-certificates-backup"
  versioning             = true

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowBucketAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.api_gateway_user.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

resource "random_password" "event_service_certificate_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "certificate_backup_secret" {
  metadata {
    name      = "certificate-store"
    namespace = var.namespace
  }
  data = {
    bucket_name                        = module.certificate_backup.bucket_name
    event_service_certificate_path     = "event-service/client.p12"
    event_service_certificate_password = random_password.event_service_certificate_password.result
  }
}
