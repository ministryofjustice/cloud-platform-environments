module "truststore_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = true

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

data "kubernetes_secret" "truststore" {
  metadata {
    name = "mutual-tls-auth"
    namespace = var.namespace
  }
}

resource "aws_s3_object" "truststore" {
  bucket  = module.truststore_s3_bucket.bucket_name
  key     = "${var.environment}-truststore.pem"
  content = data.kubernetes_secret.truststore.data["truststore-public-key"]
}
