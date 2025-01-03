/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

locals {
  # Parameters shared between the primary and read replica
  shared_db_parameters = [
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pglogical"
      apply_method = "pending-reboot"
    },
    {
      name         = "max_wal_size"
      value        = "1024"
      apply_method = "immediate"
    },
    {
      name         = "wal_sender_timeout"
      value        = "0"
      apply_method = "immediate"
    },
    {
      name         = "max_slot_wal_keep_size"
      value        = "40000"
      apply_method = "immediate"
    }
  ]
}

module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.2.2"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = true
  performance_insights_enabled = false
  db_allocated_storage         = "600"
  db_max_allocated_storage     = "700"
  enable_rds_auto_start_stop   = true

  # The days to retain backups. Must be 1 or greater to be a source for a Read Replica
  db_backup_retention_period = 7

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16.2"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.micro"
  # Security groups to allow DPR connectivity
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  # Parameters shared with the read replica
  db_parameter = local.shared_db_parameters

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

# Most of the read replica parameters are the same as the primary database above.
# See the 'Read Replica specifics' section for what differs.
module "read_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.2.2"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = true
  performance_insights_enabled = false
  db_allocated_storage         = "600"
  db_max_allocated_storage     = "700"
  enable_rds_auto_start_stop   = true

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16.2"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Read Replica specifics

  # Set the db_identifier of the source db
  replicate_source_db = module.rds.db_identifier
  db_name             = null # "db_name": conflicts with replicate_source_db

  # Set to true. No backups or snapshots are created for the read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  # Security groups to allow DPR connectivity
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  # Parameters shared with the primary DB instance
  db_parameter = local.shared_db_parameters
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    url      = "jdbc:postgresql://${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
    username = module.rds.database_username
    password = module.rds.database_password
  }
}
