/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  prepare_for_major_upgrade    = false
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = true
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  db_allocated_storage         = "100"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  deletion_protection          = true
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17"
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.medium"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  db_parameter = [
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

  enable_irsa = true
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
}
# Uncomment to create DB read replica
# module "read_replica" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
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
#   db_engine                = "postgres"
#   db_engine_version        = "17"
#   rds_family               = "postgres17"
#   db_instance_class        = "db.t4g.medium"
#   db_max_allocated_storage = "500"
#   db_allocated_storage     = "100"
#
#   # It is mandatory to set the below values to create read replica instance
#   # Set the db_identifier of the source db
#   replicate_source_db = module.rds.db_identifier
#
#   # No backups or snapshots are created for read replica
#   skip_final_snapshot        = "true"
#   db_backup_retention_period = 0
#
#   vpc_security_group_ids     = [data.aws_security_group.mp_dps_sg.id]
# }
#
# data "aws_security_group" "mp_dps_sg" {
#   name = var.mp_dps_sg_name
# }
#
# resource "kubernetes_secret" "read_replica" {
#   metadata {
#     name      = "rds-read-replica-instance-output"
#     namespace = var.namespace
#   }
#
#   data = {
#     rds_instance_endpoint = module.read_replica.rds_instance_endpoint
#     database_name         = module.read_replica.database_name
#     database_username     = module.read_replica.database_username
#     database_password     = module.read_replica.database_password
#     rds_instance_address  = module.read_replica.rds_instance_address
#   }
# }