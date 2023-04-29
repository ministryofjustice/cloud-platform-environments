module "send_legal_mail_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "send_legal_mail_s3_bucket" {
  metadata {
    name      = "send-legal-mail-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.send_legal_mail_s3_bucket.access_key_id
    secret_access_key = module.send_legal_mail_s3_bucket.secret_access_key
    bucket_arn        = module.send_legal_mail_s3_bucket.bucket_arn
    bucket_name       = module.send_legal_mail_s3_bucket.bucket_name
  }
}

