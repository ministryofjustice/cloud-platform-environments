module "upload_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
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

resource "kubernetes_secret" "upload_s3_bucket" {
  metadata {
    name      = "upload-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.upload_s3_bucket.bucket_arn
    bucket_name = module.upload_s3_bucket.bucket_name
  }
}

module "sqlserver_backup_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
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

resource "kubernetes_secret" "sqlserver_backup_s3_bucket" {
  metadata {
    name      = "sqlserver-backup-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.sqlserver_backup_s3_bucket.bucket_arn
    bucket_name = module.sqlserver_backup_s3_bucket.bucket_name
  }
}
