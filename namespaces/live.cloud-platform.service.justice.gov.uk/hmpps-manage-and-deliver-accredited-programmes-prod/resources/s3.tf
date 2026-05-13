# Existing S3 bucket — kept as-is, do not modify.
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire files after 30 days"

      expiration = [
        {
          days = 30
        },
      ]
    },
  ]

}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "im-backup-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

# New dedicated S3 bucket for SQL Server backup/restore pipeline.
# Separate from the existing s3_bucket to avoid any disruption.
module "sqlserver_backup_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # Expire old .bak files after 14 days — the DB restore only ever uses the latest file.
  # Files accumulate at ~32GB/day so this keeps storage costs bounded.
  lifecycle_rule = [
    {
      enabled = true
      id      = "expire-old-backups"

      expiration = [
        {
          days = 14
        },
      ]
    },
  ]

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
