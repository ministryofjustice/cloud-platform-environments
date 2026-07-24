module "person_match_database_backup_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0" # use the latest release

  # S3 configuration

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "person-match-database-backup-s3" {
  metadata {
    name      = "person-match-database-backup-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.person_match_database_backup_s3.bucket_arn
    bucket_name = module.person_match_database_backup_s3.bucket_name
  }
}