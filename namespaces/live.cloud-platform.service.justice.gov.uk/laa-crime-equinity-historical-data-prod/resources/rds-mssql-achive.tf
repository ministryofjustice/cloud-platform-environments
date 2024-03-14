/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/
module "rds_mssql-archive" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.2"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "4000"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # SQL Server specifics
  db_engine            = "sqlserver-web"
  db_engine_version    = "15.00.4345.5.v1"
  rds_family           = "sqlserver-web-15.0"
  db_instance_class    = "db.t3.xlarge"
  db_allocated_storage = 3000 # minimum of 20GiB for SQL Server
  option_group_name    = aws_db_option_group.sqlserver_backup_rds_option_group.name

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
}

resource "kubernetes_secret" "rds_mssql-archive" {
  metadata {
    name      = "rds-mssql-archive-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mssql-archive.rds_instance_endpoint
    database_username     = module.rds_mssql-archive.database_username
    database_password     = module.rds_mssql-archive.database_password
    rds_instance_address  = module.rds_mssql-archive.rds_instance_address
  }
}

resource "aws_db_option_group" "sqlserver_backup_rds_archive_option_group" {
  name                     = "sqlserver-backup"
  option_group_description = "Enable SQL Server Backup/Restore"
  engine_name              = "sqlserver-web"
  major_engine_version     = "15.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.sqlserver_backup_s3_iam_role.arn
    }
  }
}
