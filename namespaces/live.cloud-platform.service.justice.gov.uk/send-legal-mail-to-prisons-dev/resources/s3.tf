module "send_legal_mail_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.9.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
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
