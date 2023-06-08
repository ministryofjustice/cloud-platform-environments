module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=2.3.0"

  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  engine                      = "aurora-postgresql"
  engine_version              = "14.6"
  engine_mode                 = "provisioned"
  replica_count               = 1
  instance_type               = "db.t4g.medium"
  snapshot_identifier         = "arn:aws:rds:eu-west-2:754256621582:snapshot:hmpps-pin-phone-dev-pre-migration-20210727-1400"
  storage_encrypted           = true
  apply_immediately           = true
  vpc_name                    = var.vpc_name
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  skip_setting_when_migrated  = true

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
