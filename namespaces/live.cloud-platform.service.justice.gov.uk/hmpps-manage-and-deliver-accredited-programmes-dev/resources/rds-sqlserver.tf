module "sqlserver" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  application                = var.application
  business_unit              = var.business_unit
  db_allocated_storage       = var.db_allocated_storage
  db_engine                  = var.db_engine
  db_engine_version          = var.db_engine_version
  db_instance_class          = var.db_instance_class
  enable_rds_auto_start_stop = true
  environment_name           = var.environment-name
  infrastructure_support     = var.infrastructure_support
  is_production              = var.is_production
  license_model              = "license-included"
  namespace                  = var.namespace
  option_group_name          = aws_db_option_group.sqlserver_backup_rds_option_group.name
  rds_family                 = var.db_rds_family
  storage_type               = var.db_storage_type
  team_name                  = var.team_name
  vpc_name                   = var.vpc_name

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "0"
      apply_method = "pending-reboot"
    }
  ]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "sqlserver" {
  metadata {
    name      = "rds-sqlserver-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.sqlserver.rds_instance_endpoint
    database_identifier   = module.sqlserver.db_identifier
    database_name         = module.sqlserver.database_name
    database_password     = module.sqlserver.database_password
    database_username     = module.sqlserver.database_username
    rds_instance_address  = module.sqlserver.rds_instance_address
  }
}

resource "aws_db_option_group" "sqlserver_backup_rds_option_group" {
  name                     = "hmpps-acp-${var.environment}-sqlserver-backup"
  option_group_description = "Enable SQL Server Backup/Restore"
  engine_name              = var.db_engine
  major_engine_version     = join(".", slice(split(".", var.db_engine_version), 0, 2))

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.sqlserver_backup_s3_iam_role.arn
    }
  }
}
