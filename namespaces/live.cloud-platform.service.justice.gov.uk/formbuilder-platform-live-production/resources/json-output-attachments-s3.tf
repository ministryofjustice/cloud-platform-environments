module "json-output-attachments-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-7d"
      prefix                                 = "7d/"
      abort_incomplete_multipart_upload_days = 7
      expiration = [
        {
          days = 7
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "json-output-attachments-s3-bucket" {
  metadata {
    name      = "json-output-attachments-s3-bucket-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    bucket_arn  = module.json-output-attachments-s3-bucket.bucket_arn
    bucket_name = module.json-output-attachments-s3-bucket.bucket_name
  }
}
