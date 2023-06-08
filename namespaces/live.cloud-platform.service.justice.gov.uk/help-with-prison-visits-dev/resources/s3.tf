module "hwpv_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = true
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

resource "kubernetes_secret" "hwpv_document_s3_bucket_admin" {
  metadata {
    name      = "hwpv-document-s3-admin"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hwpv_document_s3_bucket.access_key_id
    secret_access_key = module.hwpv_document_s3_bucket.secret_access_key
    bucket_arn        = module.hwpv_document_s3_bucket.bucket_arn
    bucket_name       = module.hwpv_document_s3_bucket.bucket_name
  }
}
