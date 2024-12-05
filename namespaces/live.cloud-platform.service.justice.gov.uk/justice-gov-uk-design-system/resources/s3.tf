module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowBucketAccess",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::754256621582:role/cloud-platform-irsa-399f13871a48f20f-live"
          },
          "Action": [
            "s3:DeleteObject",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject"
          ],
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
