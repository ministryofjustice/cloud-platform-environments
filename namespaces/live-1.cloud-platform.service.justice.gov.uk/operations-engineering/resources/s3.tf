module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"
  acl    = "private"

  team_name              = var.team_name
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

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "tfstate-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id               = module.s3_bucket.access_key_id
    secret_access_key           = module.s3_bucket.secret_access_key
    reports_bucket_arn          = module.s3_bucket.bucket_arn
    reports_bucket_name         = module.s3_bucket.bucket_name
    deleted_objects_bucket_arn  = module.s3_bucket.bucket_arn
    deleted_objects_bucket_name = module.s3_bucket.bucket_name
    static_files_bucket_name    = module.s3_bucket.bucket_name
    static_files_bucket_arn     = module.s3_bucket.bucket_arn
  }
}
