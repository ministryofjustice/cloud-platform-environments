module "truststore_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
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


resource "random_password" "event_service_certificate_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

