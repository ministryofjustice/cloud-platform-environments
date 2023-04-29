module "db_backups_storage" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"

  team_name              = var.team_name
  versioning             = false
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire backups after 90 days"
      noncurrent_version_expiration = [
        {
          days = 90
        },
      ]
      expiration = [
        {
          days = 90
        },
      ]
    }
  ]
}

resource "kubernetes_secret" "db_backups_s3_production" {
  metadata {
    name      = "db-backups-s3"
    namespace = "prisoner-content-hub-production"
  }

  data = {
    access_key_id     = module.db_backups_storage.access_key_id
    secret_access_key = module.db_backups_storage.secret_access_key
    bucket_arn        = module.db_backups_storage.bucket_arn
    bucket_name       = module.db_backups_storage.bucket_name
  }
}

resource "kubernetes_secret" "db_backups_s3_staging" {
  metadata {
    name      = "db-backups-s3"
    namespace = "prisoner-content-hub-staging"
  }

  data = {
    access_key_id     = module.db_backups_storage.access_key_id
    secret_access_key = module.db_backups_storage.secret_access_key
    bucket_arn        = module.db_backups_storage.bucket_arn
    bucket_name       = module.db_backups_storage.bucket_name
  }
}

resource "kubernetes_secret" "db_backups_s3_development" {
  metadata {
    name      = "db-backups-s3"
    namespace = "prisoner-content-hub-development"
  }

  data = {
    access_key_id     = module.db_backups_storage.access_key_id
    secret_access_key = module.db_backups_storage.secret_access_key
    bucket_arn        = module.db_backups_storage.bucket_arn
    bucket_name       = module.db_backups_storage.bucket_name
  }
}
