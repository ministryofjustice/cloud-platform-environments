module "cla_backend_private_reports_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.1"
  acl                    = "private"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cla_backend_private_reports_bucket" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.cla_backend_private_reports_bucket.access_key_id
    secret_access_key = module.cla_backend_private_reports_bucket.secret_access_key
    bucket_arn        = module.cla_backend_private_reports_bucket.bucket_arn
    bucket_name       = module.cla_backend_private_reports_bucket.bucket_name
  }
}
