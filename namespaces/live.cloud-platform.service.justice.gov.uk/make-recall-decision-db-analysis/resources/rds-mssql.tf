/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/

module "rds_mssql" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # enable performance insights
  performance_insights_enabled = false

  db_engine                   = "sqlserver-ex"
  db_engine_version           = "15.00.4198.2.v1"
  db_instance_class           = "db.t3.medium"
  db_allocated_storage        = 32
  rds_family                  = "sqlserver-ex-15.0"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  option_group_name           = aws_db_option_group.ppud_backup_rds_option_group.name

  # Some engines can't apply some parameters without a reboot(ex SQL Server cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".

  # Enable auto start and stop of the RDS instances during 10:00 PM - 6:00 AM for cost saving, recommended for non-prod instances
  # enable_rds_auto_start_stop  = true

  # This will rotate the db password. Update the value to the current date.
  # db_password_rotated_date  = "dd-mm-yyyy"

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "aws_db_option_group" "ppud_backup_rds_option_group" {
  name                     = "ppud-backup"
  option_group_description = "Enable SQL Server Backup/Restore"
  engine_name              = "sqlserver-ex"
  major_engine_version     = "15.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.ppud_backup_s3_iam_role.arn
    }
  }
}

resource "kubernetes_secret" "rds_mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mssql.rds_instance_endpoint
    database_username     = module.rds_mssql.database_username
    database_password     = module.rds_mssql.database_password
    rds_instance_address  = module.rds_mssql.rds_instance_address
  }
}
