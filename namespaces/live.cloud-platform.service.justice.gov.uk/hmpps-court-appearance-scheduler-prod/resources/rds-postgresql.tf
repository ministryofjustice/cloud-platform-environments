/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  prepare_for_major_upgrade    = false
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = true
  performance_insights_enabled = false
  storage_type                 = "gp3"
  db_max_allocated_storage     = "200"
  db_allocated_storage         = "50"

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "18"
  rds_family        = "postgres18"
  db_instance_class = "db.t4g.small"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  vpc_security_group_ids     = [data.aws_security_group.mp_dps_sg.id]

  db_parameter = [
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
      value        = "5000"
      apply_method = "immediate"
    }
  ]

  enable_irsa = true
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "hmpps-court-appearance-scheduler-postgres"
    namespace = var.namespace
  }

  data = {
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    database_server       = module.rds.rds_instance_address
  }
}

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

# module "read_replica" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
#
#   vpc_name               = var.vpc_name
#   allow_minor_version_upgrade  = true
#
#   # Tags
#   application            = var.application
#   business_unit          = var.business_unit
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
#   is_production          = var.is_production
#   namespace              = var.namespace
#   team_name              = var.team_name
#
#   # PostgreSQL specifics
#   db_engine                 = "postgres"
#   db_engine_version         = "18"
#   rds_family                = "postgres18"
#   db_instance_class         = "db.t4g.small"
#   db_max_allocated_storage  = "200"
#   db_allocated_storage      = "50"
#
#   # It is mandatory to set the below values to create read replica instance
#   # Set the db_identifier of the source db
#   replicate_source_db = module.rds.db_identifier
#
#   # No backups or snapshots are created for read replica
#   skip_final_snapshot        = "true"
#   db_backup_retention_period = 0
# }

# resource "kubernetes_secret" "postgres" {
#   metadata {
#     name      = "hmpps-court-appearance-scheduler-replica"
#     namespace = var.namespace
#   }
#
#   data = {
#     database_name         = module.read_replica.database_name
#     database_username     = module.read_replica.database_username
#     database_password     = module.read_replica.database_password
#     database_server       = module.read_replica.rds_instance_address
#   }
# }