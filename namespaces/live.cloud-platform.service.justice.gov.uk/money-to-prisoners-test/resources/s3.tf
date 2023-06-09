# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

  providers = {
    aws = aws.london
  }

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  acl                           = "private"
  enable_allow_block_pub_access = true
  versioning                    = false

  lifecycle_rule = [
    {
      enabled = true
      id      = "delete email attachments after 5 weeks"
      prefix  = "emails/"

      abort_incomplete_multipart_upload_days = 2
      noncurrent_version_expiration = [
        {
          days = 35
        },
      ]
      expiration = [
        {
          days = 35
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.s3.bucket_arn
    bucket_name       = module.s3.bucket_name
    access_key_id     = module.s3.access_key_id
    secret_access_key = module.s3.secret_access_key
  }
}
