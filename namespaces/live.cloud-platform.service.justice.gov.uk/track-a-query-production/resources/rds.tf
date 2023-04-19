################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (PostgreSQL)
#################################################################################

module "track_a_query_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name                   = var.vpc_name
  team_name                  = "correspondence"
  business-unit              = "Central Digital"
  application                = "track-a-query"
  is-production              = "true"
  namespace                  = var.namespace
  db_engine                  = "postgres"
  db_engine_version          = "12"
  db_backup_retention_period = "7"
  db_name                    = "track_a_query_production"
  environment-name           = "production"
  infrastructure-support     = var.infrastructure_support

  rds_family = "postgres12"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

module "track_a_query_rds_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name = var.vpc_name

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  rds_family             = "postgres12"
  db_engine_version      = "12"

  db_name             = null # "db_name": conflicts with replicate_source_db
  replicate_source_db = module.track_a_query_rds.db_identifier

  # Set to true for replica database. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "track_a_query_rds" {
  metadata {
    name      = "track-a-query-rds-output"
    namespace = "track-a-query-production"
  }

  data = {
    rds_instance_endpoint = module.track_a_query_rds.rds_instance_endpoint
    database_name         = module.track_a_query_rds.database_name
    database_username     = module.track_a_query_rds.database_username
    database_password     = module.track_a_query_rds.database_password
    rds_instance_address  = module.track_a_query_rds.rds_instance_address

    access_key_id     = module.track_a_query_rds.access_key_id
    secret_access_key = module.track_a_query_rds.secret_access_key

    url = "postgres://${module.track_a_query_rds.database_username}:${module.track_a_query_rds.database_password}@${module.track_a_query_rds.rds_instance_endpoint}/${module.track_a_query_rds.database_name}"
  }
}

resource "kubernetes_secret" "track_a_query_rds_replica" {
  metadata {
    name      = "track-a-query-rds-replica-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.track_a_query_rds_replica.rds_instance_endpoint
    rds_instance_address  = module.track_a_query_rds_replica.rds_instance_address
    access_key_id         = module.track_a_query_rds_replica.access_key_id
    secret_access_key     = module.track_a_query_rds_replica.secret_access_key

    url = "postgres://${module.track_a_query_rds.database_username}:${module.track_a_query_rds.database_password}@${module.track_a_query_rds_replica.rds_instance_endpoint}/${module.track_a_query_rds.database_name}"
  }
}

