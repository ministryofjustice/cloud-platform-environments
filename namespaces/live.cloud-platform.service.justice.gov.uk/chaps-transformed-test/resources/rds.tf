/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/
module "rds_mssql" {
  source       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  storage_type = "gp2"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "100"
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2025-11-10" # Uncomment to rotate your database password.

  # SQL Server specifics
  db_engine            = "sqlserver-web"
  db_engine_version    = "14.00.3381.3.v1"
  rds_family           = "sqlserver-web-14.0"
  db_instance_class    = "db.t3.2xlarge"
  db_allocated_storage = 32 # minimum of 20GiB for SQL Server

  # Some engines can't apply some parameters without a reboot(ex SQL Server cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }

  ]

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  enable_irsa = true
}

resource "kubernetes_secret" "rds_mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_username = module.rds_mssql.database_username
    database_password = module.rds_mssql.database_password
  }
}

resource "kubernetes_config_map" "rds_mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mssql.rds_instance_endpoint
    rds_instance_address  = module.rds_mssql.rds_instance_address
  }
}

# module "rds_mssql_read_replica" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

#   # VPC configuration
#   vpc_name = var.vpc_name

#   # Set the db_identifier of the source db
#   replicate_source_db = module.rds_mssql.db_identifier

#   # Set to true. No backups or snapshots are created for read replica
#   skip_final_snapshot        = "true"
#   db_backup_retention_period = 0

#   db_parameter = [
#     {
#       name         = "rds.force_ssl"
#       value        = "1"
#       apply_method = "pending-reboot"
#     }

#   ]

#   # Tags
#   application            = var.application
#   business_unit          = var.business_unit
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
#   is_production          = var.is_production
#   namespace              = var.namespace
#   team_name              = var.team_name
# }

# resource "kubernetes_config_map" "rds_mssql_read_replica" {
#   metadata {
#     name      = "rds-mssql-read-replica-instance-output"
#     namespace = var.namespace
#   }

#   data = {
#     rds_instance_endpoint = module.rds_mssql_read_replica.rds_instance_endpoint
#     rds_instance_address  = module.rds_mssql_read_replica.rds_instance_address
#   }
# }
