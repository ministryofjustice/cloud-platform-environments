module "s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.0.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
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
        "Action": "s3:PutObject",
        "Resource": [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
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
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}
