module "s3_bucket" {

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
    aws = aws.london
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
        "Action": "s3:*",
        "Resource": [
          "$${bucket_arn}",
          "$${bucket_arn}/*",
          "$${bucket_arn}/*/*",
          "$${bucket_arn}/*/*/*"
        ]
      }
    ]
  }
  EOF

}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3_bucket.access_key_id
    secret_access_key = module.s3_bucket.secret_access_key
    bucket_arn        = module.s3_bucket.bucket_arn
    bucket_name       = module.s3_bucket.bucket_name
  }
}

data "kubernetes_secret" "truststore" {
  metadata {
    name      = "mutual-tls-auth"
    namespace = var.namespace
  }
}

resource "aws_s3_object" "truststore" {
  bucket  = module.s3_bucket.bucket_name
  key     = "truststore.pem"
  content = data.kubernetes_secret.truststore.data["truststore.pem"]
}
