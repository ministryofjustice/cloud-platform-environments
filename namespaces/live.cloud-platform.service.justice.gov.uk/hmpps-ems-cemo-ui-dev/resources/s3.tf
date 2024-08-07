module "uploadstore" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
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



resource "kubernetes_secret" "uploadstore_secret" {
  metadata {
    name      = "upload-store"
    namespace = var.namespace
  }
  data = {
    bucket_name                        = module.uploadstore.bucket_name   
  }
}