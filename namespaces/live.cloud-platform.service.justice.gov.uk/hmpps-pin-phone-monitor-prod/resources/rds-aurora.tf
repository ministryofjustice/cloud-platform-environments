module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=2.0.0"

  team_name                    = var.team_name
  business-unit                = var.business-unit
  application                  = var.application
  is-production                = var.is-production
  namespace                    = var.namespace
  environment-name             = var.environment-name
  infrastructure-support       = var.infrastructure-support
  engine                       = "aurora-postgresql"
  engine_version               = "13.4"
  engine_mode                  = "provisioned"
  replica_count                = 2
  instance_type                = "db.r6g.large"
  snapshot_identifier          = "arn:aws:rds:eu-west-2:754256621582:snapshot:hmpps-pin-phone-prod-pre-migration-20210730-1045"
  storage_encrypted            = true
  apply_immediately            = true
  vpc_name                     = var.vpc_name
  allow_major_version_upgrade  = true
  skip_setting_when_migrated   = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pcms_rds_aurora" {
  metadata {
    name      = "pcms-rds-aurora-output"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint        = module.rds_aurora.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.rds_aurora.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.rds_aurora.db_cluster_identifier
    database_name               = module.rds_aurora.database_name
    database_username           = module.rds_aurora.database_username
    database_password           = module.rds_aurora.database_password
    access_key_id               = module.rds_aurora.access_key_id
    secret_access_key           = module.rds_aurora.secret_access_key
  }

}
